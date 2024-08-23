import { WebPlugin } from '@capacitor/core';

import type { AudioPluginPlugin } from './definitions';

export class AudioPluginWeb extends WebPlugin implements AudioPluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
  async setupNotifications(): Promise<void> {
    return;
  }
}
