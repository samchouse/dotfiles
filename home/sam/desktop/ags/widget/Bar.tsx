import Hyprland from "gi://AstalHyprland";
import { Astal, type Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import { execAsync } from "ags/process";
import { createPoll } from "ags/time";
import { createBinding, createComputed, For } from "gnim";
import { clsx } from "../utils";
import { Backdrop } from "./Backdrop";
import { Clock } from "./Clock";
import { Tray } from "./Tray";

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  const time = createPoll("", 1000, "date '+%-I:%M %p'");
  const date = createPoll("", 1000, "date '+%a %b %-d'");

  const hyprland = Hyprland.get_default();
  const monitor = hyprland.monitors.find(
    (monitor) => monitor.name === gdkmonitor.connector,
  );
  if (!monitor) throw new Error("Missing Hyprland monitor");

  const activeWorkspace = createBinding(monitor, "activeWorkspace");
  const focusedWorkspace = createBinding(hyprland, "focusedWorkspace");

  const rawWorkspaces = createBinding(hyprland, "workspaces");
  const workspaces = createComputed(() =>
    rawWorkspaces()
      .filter((ws) =>
        ws.monitor ? ws.monitor.name === gdkmonitor.connector : false,
      )
      .sort((a, b) => (Number(a.name) > Number(b.name) ? 1 : -1))
      .map(
        (ws) =>
          [
            ws,
            ws.clients.length === 0,
            ws.id === activeWorkspace().id,
            ws.id === focusedWorkspace()?.id,
          ] as const,
      ),
  );

  const { toggleVisible, connectOnClick } = Backdrop(gdkmonitor);
  const { toggleWindow: toggleClock } = Clock({
    gdkmonitor,
    toggleBackdrop: toggleVisible,
    connectOnBackdropClick: connectOnClick,
  });

  return (
    <window
      visible
      name="bar"
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox cssName="centerbox">
        <box $type="start" hexpand={false}>
          <button
            onClicked={() => execAsync("echo hello").then(console.log)}
            hexpand
            halign={Gtk.Align.CENTER}
          >
            <label label="Welcome to AGS!" />
          </button>
        </box>
        <box $type="center" spacing={5} class="workspaces">
          <For each={workspaces}>
            {([workspace, isEmpty, isActive, isFocused]) => (
              <centerbox
                class={clsx(
                  isActive && "active",
                  isFocused ? "focused" : isEmpty && "empty",
                )}
              >
                <Gtk.GestureClick
                  onPressed={() => isActive || workspace.focus()}
                />

                <label
                  $type="center"
                  label={workspace.name}
                  halign={Gtk.Align.CENTER}
                />
              </centerbox>
            )}
          </For>
        </box>
        <box $type="end" hexpand={false} halign={Gtk.Align.END} spacing={0}>
          <Tray
            toggleBackdrop={toggleVisible}
            connectOnBackdropClick={connectOnClick}
          />

          <label class="icon" label="volume_down" />
          <button onClicked={toggleClock}>
            <box spacing={8}>
              <label label={date} />
              <label label={time} />
            </box>
          </button>
          <label label="power_settings_new" class="icon" />
        </box>
      </centerbox>
    </window>
  );
}
