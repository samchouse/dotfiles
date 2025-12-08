import AstalTray from "gi://AstalTray";
import Gio from "gi://Gio?version=2.0";
import { Gdk, Gtk } from "ags/gtk4";
import {
  type Accessor,
  createBinding,
  createComputed,
  createState,
  For,
  type Setter,
} from "gnim";
import { type Config, readConfig } from "../utils";
import { Corner } from "./Corner";

export function Tray({
  toggleBackdrop,
  connectOnBackdropClick,
}: {
  toggleBackdrop: () => void;
  connectOnBackdropClick: (onClick: () => boolean) => void;
}) {
  const config = readConfig();
  const tray = AstalTray.get_default();

  let labelRef: Gtk.Label;
  let popoverRef: Gtk.Popover;
  let revealerRef: Gtk.Revealer;

  const [inhibitExit, setInhibitExit] = createState(false);

  const rawItems = createBinding(tray, "items");
  const items = createComputed(() => {
    config.version();
    return rawItems().map(
      (item) =>
        [
          item,
          item.tooltipText || item.title || item.id,
          undefined as unknown as Gtk.PopoverMenu,
        ] as const,
    );
  });

  connectOnBackdropClick(() => {
    if (inhibitExit() || !revealerRef.revealChild) return false;
    revealerRef.revealChild = false;
    return true;
  });

  function toggleMore() {
    if (!revealerRef.revealChild) popoverRef.popup();
    toggleBackdrop();
    revealerRef.revealChild = !revealerRef.revealChild;
  }

  return (
    <box class="tray">
      <IconsList items={items} config={config} />

      <box>
        <Gtk.GestureClick onPressed={toggleMore} />

        <label
          $={(self) => {
            labelRef = self;
          }}
          class="icon"
          label="arrow_drop_down"
        />

        <popover
          $={(self) => {
            popoverRef = self;
          }}
          hasArrow={false}
          autohide={false}
        >
          <Gtk.GestureClick
            onPressed={(self, _, x, y) => {
              const widget = self
                .get_widget()
                ?.pick(x, y, Gtk.PickFlags.DEFAULT);
              if (widget instanceof Gtk.Button || widget instanceof Gtk.Image)
                return;

              toggleMore();
            }}
          />

          <revealer
            $={(self) => {
              revealerRef = self;
            }}
            vexpand={false}
            valign={Gtk.Align.START}
            onNotifyChildRevealed={(self) => {
              if (self.revealChild) return;
              popoverRef.popdown();
            }}
            onNotifyRevealChild={() => {
              labelRef.label = revealerRef.revealChild
                ? "arrow_drop_up"
                : "arrow_drop_down";
            }}
          >
            <box>
              <Corner place="top-left" r={20} />
              <IconsList
                invertVisible
                items={items}
                config={config}
                onActivate={toggleMore}
                setInhibitExit={setInhibitExit}
              />
              <Corner place="top-right" r={20} />
            </box>
          </revealer>
        </popover>
      </box>
    </box>
  );
}

function IconsList({
  items,
  config,
  onActivate,
  setInhibitExit,
  invertVisible = false,
}: {
  config: Config;
  onActivate?: () => void;
  invertVisible?: boolean;
  setInhibitExit?: Setter<boolean>;
  items: Accessor<(readonly [AstalTray.TrayItem, string, Gtk.PopoverMenu])[]>;
}) {
  function init(pop: Gtk.PopoverMenu, item: AstalTray.TrayItem, id: string) {
    const menu = new Gio.Menu();
    menu.append_section(null, item.menuModel);

    const extras = new Gio.Menu();
    extras.append(config.pinnedTray.has(id) ? "Unpin" : "Pin", "pin.toggle");
    menu.append_section(null, extras);

    pop.menuModel = menu;
    pop.insert_action_group("dbusmenu", item.actionGroup);
    item.connect("notify::action-group", () => {
      pop.insert_action_group("dbusmenu", item.actionGroup);
    });

    const pinAction = new Gio.SimpleAction({
      name: "toggle",
    });
    pinAction.connect("activate", () => {
      if (config.pinnedTray.has(id)) config.pinnedTray.delete(id);
      else config.pinnedTray.add(id);

      config.write();
    });

    const extraActionGroup = new Gio.SimpleActionGroup();
    extraActionGroup.add_action(pinAction);
    pop.insert_action_group("pin", extraActionGroup);
  }

  function showMenu(pop: Gtk.PopoverMenu, item: AstalTray.TrayItem) {
    item.about_to_show();
    pop.popup();
  }

  return (
    <box class="icons">
      <For each={items}>
        {([item, id, pop]) => (
          <box visible={invertVisible !== config.pinnedTray.has(id)}>
            <box>
              <Gtk.GestureClick
                onPressed={(_, __, x, y) => {
                  if (item.isMenu) showMenu(pop, item);
                  else {
                    onActivate?.();
                    item.activate(x, y);
                  }
                }}
              />
              <Gtk.GestureClick
                button={Gdk.BUTTON_SECONDARY}
                onPressed={() => showMenu(pop, item)}
              />

              <image gicon={createBinding(item, "gicon")} pixelSize={20} />
            </box>

            <Gtk.PopoverMenu
              $={(self) => {
                pop = self;
                init(self, item, id);
              }}
              hasArrow={false}
              onShow={() => {
                if (setInhibitExit !== undefined) setInhibitExit(true);
              }}
              onHide={() => {
                if (setInhibitExit !== undefined)
                  setTimeout(() => setInhibitExit(false), 100);
              }}
            />
          </box>
        )}
      </For>
    </box>
  );
}
