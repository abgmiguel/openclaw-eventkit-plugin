import type { OpenClawConfig } from "../config/config";

export type QuickstartGatewayDefaults = {
  hasExisting: boolean;
};

const DEFAULT_DANGEROUS_NODE_DENY_COMMANDS = [
  "camera.snap",
  "camera.clip",
  "screen.record",
  "calendar.add",
  "calendar.update",
  "contacts.add",
  "reminders.add",
  "reminders.update",
];

export function applyDefaultDangerousDenyCommands(params: {
  nextConfig: OpenClawConfig;
  quickstartGateway: QuickstartGatewayDefaults;
}): OpenClawConfig {
  const { nextConfig, quickstartGateway } = params;

  if (
    !quickstartGateway.hasExisting &&
    nextConfig.gateway?.nodes?.denyCommands === undefined &&
    nextConfig.gateway?.nodes?.allowCommands === undefined &&
    nextConfig.gateway?.nodes?.browser === undefined
  ) {
    return {
      ...nextConfig,
      gateway: {
        ...nextConfig.gateway,
        nodes: {
          ...nextConfig.gateway?.nodes,
          denyCommands: [...DEFAULT_DANGEROUS_NODE_DENY_COMMANDS],
        },
      },
    };
  }

  return nextConfig;
}
