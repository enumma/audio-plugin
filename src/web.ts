import { WebPlugin } from '@capacitor/core';

import type { AudioPluginPlugin } from './definitions';

export class AudioPluginWeb extends WebPlugin implements AudioPluginPlugin {
  async setupNotifications(): Promise<void> {
    console.log('setupNotifications');
    return;
  }
}
