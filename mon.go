package main

import (
	"bufio"
	"fmt"
	//"io/ioutil"
	"log"	
 	"os"
	//"strings"
	"syscall"
	"gopkg.in/gomail.v2"
)

func getNoreplyPassword() (pw string) {
	f, _ := os.Open("/home/scott/pw/.noreplypw")
	scanner := bufio.NewScanner(f)
	line := scanner.Text()
	fmt.Println(line)
	pw = line
	return pw
}


func main() {

	pw := getNoreplyPassword()
	//pw := strings.Trim(getNoreplyPassword(), "\n")

	fmt.Print("DEBUG\n")
	fmt.Println(pw)

	stat	:= syscall.Statfs_t{}
	err	:= syscall.Statfs("/", &stat)

	if err != nil {
		fmt.Println(err.Error())
		return
	}

	used	:= stat.Bfree - stat.Bavail
	blocks	:= stat.Blocks
	pct	:= float64(used) / float64(blocks) * float64(100.0)

	fmt.Printf("%.2f\n", pct)

	//threshhold := float64(95.0)
	//threshhold := float64(1.0)

	//if pct >= threshhold {
		fmt.Printf("sending mail...\n");
		m := gomail.NewMessage()
		m.SetHeader("From", "noreply@r1soft.com")
		//m.SetHeader("To", "scott.gillespie@r1soft.com", "alex.vongluck@r1soft.com", "stan.love@r1soft.com")
		m.SetHeader("To", "scott.gillespie@r1soft.com")
		m.SetHeader("Subject", "SBJENKINS root filesystem at or over 95% full.")
		m.SetBody("text/html", "jenkins-root filesystem above 95% used. Please cleanup some old builds, if possible.")

		d := gomail.NewDialer("smtp.office365.com", 587, "noreply@r1soft.com", pw)	
		//d := gomail.NewDialer("smtp.office365.com", 587, "noreply@r1soft.com", "NoR3plyR1$0ft")

		errn := d.DialAndSend(m)
		if errn != nil {
			log.Fatal(errn)
		}
	//}
}
