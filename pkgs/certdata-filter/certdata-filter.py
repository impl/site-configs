# SPDX-FileCopyrightText: 2026 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from hashlib import sha1
import json
import re
import sys
from typing import Any, Protocol, Self

from buildcatrust import der_x509, x509_consts


@dataclass(kw_only=True)
class CertdataBytes:
    contents: bytes
    postlude: bytes

    def write_to(self, writer):
        writer.write(self.contents)
        writer.write(self.postlude)


@dataclass(kw_only=True)
class CertdataAttr:
    prelude: bytes
    name: CertdataBytes
    type: CertdataBytes
    value: CertdataBytes

    def write_to(self, writer):
        writer.write(self.prelude)
        self.name.write_to(writer)
        self.type.write_to(writer)
        self.value.write_to(writer)


ATTR_REGEX = re.compile(
    rb"(?P<prelude>\s*)" +
    rb"(?P<name>\S+)(?P<name_postlude>\s+)" +
    rb"(?P<type>\S+)(?P<type_postlude>\s*)" +
    rb"(?P<rest>.*)",
    flags=re.DOTALL
)
VALUE_REGEX = re.compile(
    rb'(?P<value>"(?:[^"\\]|\\.)*"|\S+)(?P<value_postlude>\s*)',
    flags=re.DOTALL
)


@dataclass(kw_only=True)
class CertdataObject:
    bufs: list[CertdataAttr | bytes]

    def write_to(self, writer):
        for buf in self.bufs:
            if isinstance(buf, CertdataAttr):
                buf.write_to(writer)
            else:
                writer.write(buf)

    def find_attr(self, name: bytes) -> CertdataAttr | None:
        for buf in self.bufs:
            if not isinstance(buf, CertdataAttr):
                continue
            if buf.name.contents == name:
                return buf
        return None

    @classmethod
    def read_from(cls: type[Self], it: Iterable[bytes]) -> Iterable[Self]:
        reading_attrs = False
        obj = cls(bufs=[])
        for line in it:
            stripped_line = line.strip()
            if not stripped_line or stripped_line.startswith(b"#"):
                obj.bufs.append(line)
                continue
            elif not reading_attrs:
                assert stripped_line == b"BEGINDATA"
                obj.bufs.append(line)
                yield obj
                obj = cls(bufs=[])
                reading_attrs = True
            else:
                # Read the name and the type. Then decide what to do
                # next.
                attr_match = ATTR_REGEX.fullmatch(line)
                value = b""
                value_postlude = b""
                if attr_match.group("type") == b"MULTILINE_OCTAL":
                    # In this case rest must be empty.
                    assert not attr_match.group("rest")
                    # Read values line by line until we get to END,
                    # which is our value postlude.
                    for value_line in it:
                        if value_line == b"END\n":
                            value_postlude = value_line
                            break
                        value += value_line
                else:
                    # The value will be in rest.
                    value_match = VALUE_REGEX.fullmatch(
                        attr_match.group("rest"),
                    )
                    value = value_match.group("value")
                    value_postlude = value_match.group("value_postlude")

                attr = CertdataAttr(
                    prelude=attr_match.group("prelude"),
                    name=CertdataBytes(
                        contents=attr_match.group("name"),
                        postlude=attr_match.group("name_postlude"),
                    ),
                    type=CertdataBytes(
                        contents=attr_match.group("type"),
                        postlude=attr_match.group("type_postlude"),
                    ),
                    value=CertdataBytes(
                        contents=value,
                        postlude=value_postlude,
                    ),
                )
                if attr.name.contents == b"CKA_CLASS":
                    yield obj
                    obj = cls(bufs=[])
                obj.bufs.append(attr)
        yield obj


def decode_nss_utf8(attr: CertdataAttr) -> str:
    assert attr
    assert attr.type.contents == b"UTF8"
    assert attr.value.contents[0] == ord('"')
    assert attr.value.contents[-1] == ord('"')
    return attr.value.contents[1:-1].replace(b'\\"', b'"').decode("utf-8")


def decode_nss_bytes(attr: CertdataAttr) -> bytes:
    assert attr
    assert attr.type.contents == b"MULTILINE_OCTAL"
    return (
        attr.value.contents.replace(b"\n", b"")
        .decode("unicode-escape")
        .encode("latin1")
    )


@dataclass(kw_only=True)
class Certificate:
    label: str
    subject: dict[str, Any]
    sha1_digest: bytes

    @classmethod
    def from_certdata_object(cls, obj: CertdataObject):
        obj_class = obj.find_attr(b"CKA_CLASS")
        assert obj_class.type.contents == b"CK_OBJECT_CLASS"
        assert obj_class.value.contents == b"CKO_CERTIFICATE"
        label = decode_nss_utf8(obj.find_attr(b"CKA_LABEL"))
        cert_type_attr = obj.find_attr(b"CKA_CERTIFICATE_TYPE")
        assert cert_type_attr
        assert cert_type_attr.type.contents == b"CK_CERTIFICATE_TYPE"
        assert cert_type_attr.value.contents == b"CKC_X_509"
        cert_bytes = decode_nss_bytes(obj.find_attr(b"CKA_VALUE"))
        cert, _ = der_x509.Certificate.from_der(cert_bytes)
        subject_dn, _ = der_x509.DistinguishedName.from_der(
            cert.tbs_certificate.subject
        )
        subject_bits = {
            str(oid): value for rdn in subject_dn.bits for oid, value in rdn
        }
        return cls(
            label=label,
            subject=subject_bits,
            sha1_digest=sha1(cert_bytes).digest(),
        )


DN_ATTRIBUTES_BY_NAME = {
    attr.name: attr
    for attr in x509_consts.ATTRIBUTES.values()
    if attr.name
}


class CertificatePermitter(Protocol):

    def permit(self, cert: Certificate) -> bool: ...


@dataclass(kw_only=True, frozen=True)
class Label:
    label: str

    def __post_init__(self):
        assert isinstance(self.label, str)

    def permit(self, cert: Certificate) -> bool:
        return cert.label == self.label


@dataclass(kw_only=True, frozen=True)
class Subject:
    fields: dict[str, Any]

    def __post_init__(self):
        assert isinstance(self.fields, dict)
        for attr in list(self.fields):
            attr_lower = attr.casefold()
            if attr_lower in DN_ATTRIBUTES_BY_NAME:
                attr_oid = str(DN_ATTRIBUTES_BY_NAME[attr_lower])
                self.fields[attr_oid] = self.fields.pop(attr)

    def permit(self, cert: Certificate) -> bool:
        return (
            cert.subject.items() & self.fields.items() == self.fields.items()
        )


ALLOWLIST_TYPES = {
    "label": lambda value: Label(label=value),
    "subject": lambda value: Subject(fields=value),
}

ALLOWLIST_REWRITES = {
    b"CKT_NSS_TRUSTED": True,
    b"CKT_NSS_TRUSTED_DELEGATOR": True,
    b"CKT_NSS_MUST_VERIFY_TRUST": False,
    b"CKT_NSS_NOT_TRUSTED": False,
    b"CKT_NSS_TRUST_UNKNOWN": True,
    b"CKT_NSS_VALID_DELEGATOR": True,
}


@dataclass(kw_only=True, frozen=True)
class Allowlist:
    permitters: list[CertificatePermitter]

    @classmethod
    def from_raw(cls, items):
        permitters = []
        assert isinstance(items, Iterable)
        for item in items:
            assert isinstance(item, Mapping)
            assert len(item) == 1
            key, value = next(iter(item.items()))
            assert key in ALLOWLIST_TYPES
            permitters.append(ALLOWLIST_TYPES[key](value))
        return cls(permitters=permitters)

    def permit(self, cert: Certificate) -> bool:
        return any(permitter.permit(cert) for permitter in self.permitters)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(
            f"Usage: {sys.argv[0]} <allowlist> <certdata1> " +
            "[<certdata2> [...]]",
            file=sys.stderr
        )
        sys.exit(1)

    with open(sys.argv[1], "rb") as f:
        allowlist = Allowlist.from_raw(json.load(f))

    # First pass: read all objects, identify permitted certificates.
    objs = []
    permitted_certs = set()

    for arg in sys.argv[2:]:
        with open(arg, "rb") as f:
            for obj in CertdataObject.read_from(f):
                objs.append(obj)
                obj_class = obj.find_attr(b"CKA_CLASS")
                if obj_class is None:
                    continue

                assert obj_class.type.contents == b"CK_OBJECT_CLASS"
                if obj_class.value.contents == b"CKO_CERTIFICATE":
                    cert = Certificate.from_certdata_object(obj)
                    if allowlist.permit(cert):
                        permitted_certs.add(cert.sha1_digest)

    # Second pass: rewrite trust, print.
    for obj in objs:
        obj_class = obj.find_attr(b"CKA_CLASS")
        if obj_class and obj_class.value.contents == b"CKO_NSS_TRUST":
            label = decode_nss_utf8(obj.find_attr(b"CKA_LABEL"))
            sha1_digest = decode_nss_bytes(
                obj.find_attr(b"CKA_CERT_SHA1_HASH"),
            )
            if sha1_digest not in permitted_certs:
                # Rewrite all trust values other than
                # CKT_NSS_NOT_TRUSTED.
                for buf in obj.bufs:
                    if not isinstance(buf, CertdataAttr):
                        continue
                    if buf.type.contents != b"CK_TRUST":
                        continue
                    rewrite = ALLOWLIST_REWRITES[buf.value.contents]
                    if not rewrite:
                        continue
                    buf.value.contents = b"CKT_NSS_MUST_VERIFY_TRUST"
            else:
                print(f"Permitted {label}", file=sys.stderr)

        obj.write_to(sys.stdout.buffer)
