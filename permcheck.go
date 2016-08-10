package main

import (
	"fmt"
	"os"
	"strings"
)

var directories []string = []string {

	"/home/continuum",
	"/storage",
	"/storage01/replication",
	"/storage02/replication",
	"/storage03/replication",
	"/storage04/replication",
	"/storage05/replication",
	"/storage06/replication",
	"/storage07/replication",
	"/storage08/replication",
	"/storage09/replication",

}

func checkDirPerms(dirname string) {

	hostname, _ := os.Hostname()

	fileInfo, err := os.Lstat(dirname)
	if err != nil {
		fmt.Printf("Error getting directory info for dir: %s\n", dirname)
		return
	}

	mode := strings.Trim(fileInfo.Mode().Perm().String(), "\n")

	var wantedMode = ""

	if dirname == "/home/continuum" {
		wantedMode = "-rwxr-xr-x"
	} else if dirname == "/storage" {
		wantedMode = "-rwxrwxrwx"
	} else {
		wantedMode = "-rwx------"
	}

	ret := strings.Compare(mode, wantedMode)
	if ret == 0 {
		fmt.Println("GOOD " + hostname + " " + dirname + " perms: \t\t", mode)
	} else {
		fmt.Println("BAD  " + hostname + " " + dirname + " perms: \t\t", mode)
	}
}

func main() {

	for i := range directories {
		checkDirPerms(directories[i])
	}

}
