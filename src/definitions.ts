export interface AudioPluginPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
