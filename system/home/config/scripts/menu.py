#!/usr/bin/env python3
import npyscreen
import os
import threading
import time

CARTRIDGE_MOUNT = "/mnt/cartridge"
FLAG_FILE = "/tmp/bbos_play_game"

# --- Cartridge detection ---
def detect_cartridge(callback):
    last_state = False
    while True:
        mounted = os.path.ismount(CARTRIDGE_MOUNT)
        if mounted != last_state:
            last_state = mounted
            callback(mounted)
        time.sleep(2)

# --- Menu Form ---
class MenuForm(npyscreen.FormBaseNew):
    def create(self):
        self.options = ["Settings", "Music Player", "Shutdown", "Quit"]

        # Check cartridge at startup
        if os.path.ismount(CARTRIDGE_MOUNT):
            self.options.insert(0, "Play Cartridge")

        self.menu = self.add(
            npyscreen.SelectOne,
            values=self.options,
            max_height=6,
            scroll_exit=True
        )
        self.menu.when_value_edited = self.option_selected
        self.add_handlers({"^Q": self.exit_app})

    def option_selected(self):
        choice = self.menu.get_selected_objects()
        if not choice:
            return
        selected = choice[0]

        if selected == "Play Cartridge":
            with open(FLAG_FILE, "w") as f:
                f.write("play\n")
            self.exit_app()
        elif selected == "Shutdown":
            os.system("systemctl poweroff")
        elif selected == "Quit":
            self.exit_app()
        self.display()

    def update_menu(self, cartridge_inserted):
        if cartridge_inserted and "Play Cartridge" not in self.options:
            self.options.insert(0, "Play Cartridge")
        elif not cartridge_inserted and "Play Cartridge" in self.options:
            self.options.remove("Play Cartridge")

        self.menu.values = self.options
        self.menu.display()

    def exit_app(self, *args, **keywords):
        # self.parentApp.setNextForm(None)
        # self.editing = False
        exit()

# --- TUI App ---
class ConsoleMenu(npyscreen.NPSAppManaged):
    def onStart(self):
        self.main_form = self.addForm("MAIN", MenuForm, name="Game Console")
        threading.Thread(
            target=detect_cartridge,
            args=(self.main_form.update_menu,),
            daemon=True
        ).start()

if __name__ == "__main__":
    app = ConsoleMenu()
    app.run()
