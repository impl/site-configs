// SPDX-FileCopyrightText: 2022 Noah Fontes
//
// SPDX-License-Identifier: CC-BY-NC-SA-4.0

(() => {
  'use strict';

  window.setInterval(() => {
    document.getElementById('app').dispatchEvent(new Event('mousemove'));
  }, 60000);
})();
