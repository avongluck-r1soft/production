package main

import (
	"fmt"
	"io/ioutil"
	"log"	
	"strings"
	"syscall"
	"gopkg.in/gomail.v2"
)

func diskSpace(path string) (total, free int, err error) {
	s := syscall.Statfs_t{}
	err = syscall.Statfs(path, &s)
	if err != nil {
		fmt.Printf("%s\n", err.Error())
	}
	total = int(s.Bsize) * int(s.Blocks)
	free = int(s.Bsize) * int(s.Bfree)
	return
}

func getNoreplyPassword() string {
	file, err := ioutil.ReadFile("/home/zadmin/bin/.noreplypw")
	if err != nil {
		fmt.Println(err.Error())
	}
	pw := string(file)
	return pw
}

func main() {

	total, free, _ := diskSpace("/")

	pct := float64(100.00) - ( float64(free) / float64(total) * 100.0 )
	fmt.Printf("pct used for root filesystem, /, on sbjenkins: %.2f\n", pct)

	pw := strings.Trim(getNoreplyPassword(), "\n")

	threshhold := float64(90.0)

	if pct >= threshhold {
		fmt.Printf("sending mail...\n");
		m := gomail.NewMessage()
		m.SetHeader("From", "noreply@r1soft.com")
		m.SetHeader("To", "scott.gillespie@r1soft.com", "alex.vongluck@r1soft.com", "stan.love@r1soft.com", "keith.powe@r1soft.com")
		//m.SetHeader("To", "scott.gillespie@r1soft.com")
		m.SetHeader("Subject", "SBJENKINS root filesystem at or over 90 percent full.")
		m.SetBody("text/html", "jenkins-root filesystem above 90% used. Please cleanup some old builds, if possible.")
		d := gomail.NewDialer("smtp.office365.com", 587, "noreply@r1soft.com", pw)

		errn := d.DialAndSend(m)
		if errn != nil {
			log.Fatal(errn)
		}
	}
}
