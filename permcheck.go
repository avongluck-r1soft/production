package main

import (
	"fmt"
	"os"
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

func checkDirInfo(dirname string) {
	hostname, _ := os.Hostname()
	fileInfo, err := os.Lstat(dirname)
	if err != nil {
		fmt.Printf("Error getting directory info for dir: %s\n", dirname)
		return
	}

	if dirname == "/home/continuum" {
		fmt.Println(hostname + " dir: " + dirname + " perms: \t\t", fileInfo.Mode())
	} else if dirname == "/storage" {
		fmt.Println(hostname + " dir: " + dirname + " perms: \t\t\t", fileInfo.Mode())
	} else {
		fmt.Println(hostname + " dir: "+dirname+" perms: \t", fileInfo.Mode())
	}
}

func main() {
	for i := range directories {
		checkDirInfo(directories[i])
	}
}
