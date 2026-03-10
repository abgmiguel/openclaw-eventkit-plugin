import { describe, expect, it } from "vitest";
import { applyDefaultDangerousDenyCommands } from "./onboarding.gateway-config";

describe("applyDefaultDangerousDenyCommands", () => {
  it("seeds dangerous deny commands for new gateway setup", () => {
    const result = applyDefaultDangerousDenyCommands({
      nextConfig: {},
      quickstartGateway: { hasExisting: false },
    });

    expect(result.gateway?.nodes?.denyCommands).toEqual([
      "camera.snap",
      "camera.clip",
      "screen.record",
      "calendar.add",
      "calendar.update",
      "contacts.add",
      "reminders.add",
      "reminders.update",
    ]);
  });

  it("does not overwrite existing command settings", () => {
    const result = applyDefaultDangerousDenyCommands({
      nextConfig: {
        gateway: {
          nodes: {
            denyCommands: ["camera.snap"],
          },
        },
      },
      quickstartGateway: { hasExisting: false },
    });

    expect(result.gateway?.nodes?.denyCommands).toEqual(["camera.snap"]);
  });

  it("does not seed defaults when gateway already exists", () => {
    const result = applyDefaultDangerousDenyCommands({
      nextConfig: {},
      quickstartGateway: { hasExisting: true },
    });

    expect(result.gateway?.nodes?.denyCommands).toBeUndefined();
  });
});
