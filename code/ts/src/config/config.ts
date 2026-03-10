export type OpenClawConfig = {
  gateway?: {
    nodes?: {
      allowCommands?: string[];
      denyCommands?: string[];
      browser?: unknown;
    };
  };
};
