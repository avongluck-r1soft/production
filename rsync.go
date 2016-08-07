package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

func Rsync(source string, user string, host string, dest string) (err os.Error) {
	r_path, err := exec.LookPath("rsync")
	if err != nil {
		fmt.Printf("rsync command not found: %s\n", err)
		return
	}

	cmdargs := []string{ r_path, "-avz", source, user + "@" + host + ":" + dest }

	cmd, err := exec.Run(r_path, cmdargs, os.Environ(), "", exec.DevNull, exec.DevNull, exec.Pipe)

	defer cmd.Close()

	if err != nil {
		fmt.Printf("rsync error: %s\n", err)
		return
	}

	waitmsg, err := cmd.Wait(0)
	if err != nil {
		fmt.Printf("Error reading from stderr: %s\n", err)
	}

	if len(buf) > 0 {
		log.Stdout(string(buf))
	}

	if waitmsg.ExitStatus() != 0 {
		log.Stderrf("rsync returned with an error status: %s\n", waitmsg)
		return
	}

	log.Stderrf("rsync completed.\n")
	return
}

