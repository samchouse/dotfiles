import Hyprland from "gi://AstalHyprland";
import Wireplumber from "gi://AstalWp";
import type GLib from "gi://GLib?version=2.0";
import { Astal, type Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import { execAsync } from "ags/process";
import { createPoll } from "ags/time";
import { createBinding, createComputed, createState, For } from "gnim";
import { clsx } from "../utils";
import { Audio } from "./Audio";
import { Backdrop } from "./Backdrop";
import { Clock } from "./Clock";
import { Tray } from "./Tray";
import { VolumeIcon } from "./VolumeIcon";

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  const time = createPoll("", 1000, "date '+%-I:%M %p'");
  const date = createPoll("", 1000, "date '+%a %b %-d'");

  const wp = Wireplumber.get_default();
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
  const { toggleWindow: toggleAudio } = Audio({
    gdkmonitor,
    toggleBackdrop: toggleVisible,
    connectOnBackdropClick: connectOnClick,
  });

  const { defaultSpeaker: speaker } = wp;
  let volumeHoverTimeout: GLib.Source | null = null;
  const [revealVolume, setRevealVolume] = createState(false);

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
        <box $type="center" spacing={5} class="workspaces wrapper">
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

          <button onClicked={toggleAudio} class="wrapper">
            <Gtk.EventControllerMotion
              onEnter={() => {
                volumeHoverTimeout = setTimeout(() => {
                  setRevealVolume(true);
                  setTimeout(() => {});
                }, 500);
              }}
              onLeave={() => {
                if (volumeHoverTimeout) clearTimeout(volumeHoverTimeout);
                setRevealVolume(false);
              }}
            />

            <box class="volume">
              <revealer
                revealChild={revealVolume}
                transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
              >
                <label
                  label={createComputed(
                    () =>
                      `${(createBinding(speaker, "volume")() * 100).toFixed(0)}%`,
                  )}
                />
              </revealer>
              <VolumeIcon class="medium" />
            </box>
          </button>
          <button onClicked={toggleClock} class="wrapper">
            <box spacing={8}>
              <label label={date} />
              <label label={time} />
            </box>
          </button>
          <button class="wrapper">
            <label label="settings" class="icon medium" />
          </button>
        </box>
      </centerbox>
    </window>
  );
}
