import Wireplumber from "gi://AstalWp";
import type GLib from "gi://GLib?version=2.0";
import { Astal, type Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import { createBinding, createComputed } from "gnim";

export function Osd(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor;

  let windowRef: Gtk.Window;
  let sliderRef: Gtk.Scale;

  const wp = Wireplumber.get_default();
  const { defaultSpeaker: speaker } = wp;

  let timeout: GLib.Source | null = null;
  function makeVisible() {
    windowRef.visible = true;
    if (timeout) clearTimeout(timeout);
    timeout = setTimeout(() => {
      windowRef.visible = false;
    }, 2000);
  }

  let firstVolume = true;
  speaker.connect("notify::volume", () => {
    if (firstVolume) {
      firstVolume = false;
      return;
    }

    makeVisible();
  });

  let firstMute = true;
  speaker.connect("notify::mute", (self) => {
    if (firstMute) {
      firstMute = false;
      return;
    }

    if (self.mute) sliderRef.add_css_class("muted");
    else sliderRef.remove_css_class("muted");
    makeVisible();
  });

  return (
    <window
      $={(self) => {
        windowRef = self;
      }}
      visible={false}
      class="osd"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={TOP | RIGHT}
      application={app}
      marginTop={56}
      marginRight={20}
    >
      <Gtk.GestureClick
        propagationPhase={Gtk.PropagationPhase.CAPTURE}
        onPressed={(self) => self.set_state(Gtk.EventSequenceState.CLAIMED)}
      />
      <box>
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
          class="icon"
        />
        <slider
          $={(self) => {
            sliderRef = self;
          }}
          value={createBinding(speaker, "volume")}
          widthRequest={200}
        />
      </box>
    </window>
  );
}
