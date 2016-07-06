package main

import (
	"bufio"
	"fmt"
	//"io/ioutil"
	//"log"	
 	"os"
	//"strings"
	"syscall"
	//"gopkg.in/gomail.v2"
)

// Space returns total and free bytes available in a directory, e.g. `/`.
// Think of it as "df" UNIX command.
func diskSpace(path string) (total, free int, err error) {
	s := syscall.Statfs_t{}
	err = syscall.Statfs(path, &s)
	if err != nil {
		return
	}
	total = int(s.Bsize) * int(s.Blocks)
	free = int(s.Bsize) * int(s.Bfree)
	return
}

func main() {
	total, free, err := diskSpace("/")

	fmt.Printf("%d\t%d\t%s\n", total, free, err)

	pct := float64(100.00) - ( float64(free) / float64(total) * 100.0 )
 	fmt.Printf("%.2f\n", pct)


	//pw := strings.Trim(getNoreplyPassword(), "\n")

	//threshhold := float64(95.0)
	threshhold := float64(1.0)

	if pct >= threshhold {
		fmt.Printf("sending mail...\n");
		m := gomail.NewMessage()
		m.SetHeader("From", "noreply@r1soft.com")
		m.SetHeader("To", "scott.gillespie@r1soft.com", "alex.vongluck@r1soft.com", "stan.love@r1soft.com")
		m.SetHeader("To", "scott.gillespie@r1soft.com")
		m.SetHeader("Subject", "SBJENKINS root filesystem at or over 95% full.")
		m.SetBody("text/html", "jenkins-root filesystem above 95% used. Please cleanup some old builds, if possible.")

		d := gomail.NewDialer("smtp.office365.com", 587, "noreply@r1soft.com", pw)	

		errn := d.DialAndSend(m)
		if errn != nil {
			log.Fatal(errn)
		}
	}
}
