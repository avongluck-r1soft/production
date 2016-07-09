//
// mon.go - monitor root filesystem, alert if above THRESHHOLD value.
//          Feel free to hack on this. Have fun. -scott
//

package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strings"
	"syscall"
	"gopkg.in/gomail.v2"
)

func getDiskSpace(path string) (total, free int, err error) {
	s := syscall.Statfs_t{}
	err = syscall.Statfs(path, &s)
	if err != nil {
		fmt.Printf("%s\n", err.Error())
	}
	total = int(s.Bsize) * int(s.Blocks)
	free  = int(s.Bsize) * int(s.Bfree)
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

func isRootFull(THRESHHOLD float64) bool {
	total, free, _ := getDiskSpace("/")

	pctUsed := float64(100.00) - ( float64(free) / float64(total) * 100.0 )

	if pctUsed >= THRESHHOLD {
		fmt.Printf("percent used for root filesystem, /, on sbjenkins: %.2f\n", pctUsed)
		return true
	} else {
		return false
	}
}

func sendEmail(pw string) {
	m := gomail.NewMessage()
	m.SetHeader("From","noreply@r1soft.com")
	m.SetHeader("To","scott.gillespie@r1soft.com","alex.vongluck@r1soft.com","stan.love@r1soft.com")
	m.SetHeader("Subject","SBJENKINS root filesystem at or over 85 percent full.")
	m.SetBody("text/html","jenkins-root filesystem above 85% used. Please cleanup some old builds, if possible.")
	d := gomail.NewDialer("smtp.office365.com",587,"noreply@r1soft.com",pw)

	err := d.DialAndSend(m)

	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	THRESHHOLD := float64(85.0)
	pw := strings.Trim(getNoreplyPassword(), "\n")
	if (isRootFull(THRESHHOLD)) {
		fmt.Printf("sending email...\n")
		sendEmail(pw)
	}
}
