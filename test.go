package main

import (
    "fmt"
    "syscall"
)

func main() {
    stat := syscall.Statfs_t{}
    err  := syscall.Statfs("/", &stat)
    if err != nil {
        fmt.Println(err.Error())
	return
    }

    s := fmt.Sprintf(`

    Statfs_t {
        Type     %d
        Bsize    %d
        Blocks   %d
        Bfree    %d
        Bavail   %d
        Files    %d
        Ffree    %d
        Frsize   %d
        Flags    %d
    }
        `, stat.Type,
	   stat.Bsize,
	   stat.Blocks,
	   stat.Bfree,
	   stat.Bavail,
	   stat.Files,
	   stat.Ffree,
	   stat.Frsize,
	   stat.Flags)

    fmt.Println(s)

    n := ( stat.Bfree-stat.Bavail )
    fmt.Println(n)
    m := ( stat.Blocks )
    fmt.Println(m)

    p := float64(n) / float64(m) * float64(100.0)
    fmt.Printf("%.2f", p)
}
	   



