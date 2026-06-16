import Wireplumber from "gi://AstalWp";
import { createBinding, createComputed } from "gnim";
import { clsx } from "../utils";

export function VolumeIcon({ class: className }: { class?: string }) {
  const wp = Wireplumber.get_default();
  const { defaultSpeaker: speaker } = wp;

  return (
    <label
      label={createComputed(() => {
        const volume = createBinding(speaker, "volume")();
        return createBinding(speaker, "mute")()
          ? "no_sound"
          : volume === 0
            ? "no_sound"
            : volume < 0.5
              ? "volume_down"
              : "volume_up";
      })}
      class={clsx("icon", className)}
    />
  );
}
