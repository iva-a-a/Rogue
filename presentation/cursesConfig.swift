//
//  cursesConfig.swift
//  rogue

import Darwin.ncurses

public func configureCurses() {
    initscr()
    raw()
    noecho()
    curs_set(0)
    keypad(stdscr, true)
    start_color()

    init_pair(1, Int16(COLOR_WHITE), Int16(COLOR_BLACK))
    init_pair(2, Int16(COLOR_RED), Int16(COLOR_BLACK))
    init_pair(3, Int16(COLOR_YELLOW), Int16(COLOR_BLACK))
    init_pair(4, Int16(COLOR_BLUE), Int16(COLOR_BLACK))
    init_pair(5, Int16(COLOR_GREEN), Int16(COLOR_BLACK))
    init_pair(6, Int16(COLOR_WHITE), Int16(COLOR_BLACK));
}
