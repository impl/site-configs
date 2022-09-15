// SPDX-FileCopyrightText: 2022 Noah Fontes
//
// SPDX-License-Identifier: CC-BY-NC-SA-4.0

'use strict';

(async () => {
  const config = await (await fetch(browser.runtime.getURL("config.json"))).json();
  for (const userScript of config) {
    await browser.userScripts.register(userScript);
  };
})();
