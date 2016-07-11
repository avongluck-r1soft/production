//
// mon.go - monitor root filesystem, alert if above THRESHHOLD value.
//          Feel free to hack on this. Have fun. -scott
//          Mongo likes candy! -Mongo, pawn in game of life. 

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

//func checkJenkinsProc() {
//}

type email struct {
	From 			string
	NoReplyAcct 		string
	To 			string
	ToAcct1			string
	ToAcct2			string
	ToAcct3			string
	RootFullSubj		string
	RootFullMsg		string
	RootFullBody1		string
	RootFullBody2		string
	JenkinsDownSubj		string
	JenkinsDownMsg		string
	JenkinsDownBody1	string
	JenkinsDownBody2	string
	SMTPServer		string
	SMTPPort		int
}

func sendRootFullEmail(pw string) {
	m := gomail.NewMessage()

	e := email{}

	e.From 	 	= "From"
	e.NoReplyAcct   = "noreply@r1soft.com"
	e.To  	 	= "To"
	e.ToAcct1  	= "scott.gillespie@r1soft.com"
	e.ToAcct2	= "alex.vongluck@r1soft.com"
	e.ToAcct3 	= "stan.love@r1soft.com"
	e.RootFullSubj	= "Subject"
	e.RootFullMsg 	= "SBJENKINS root filesystem full."
	e.RootFullBody1	= "text/html"
	e.RootFullBody2 = "jenkins-root filesystem is full. Please clenup some old builds."
	e.SMTPServer	= "smtp.office365.com"
	e.SMTPPort	= 587

	m.SetHeader(e.From, e.NoReplyAcct)
	m.SetHeader(e.To, e.ToAcct1, e.ToAcct2, e.ToAcct3)
	m.SetHeader(e.RootFullSubj, e.RootFullMsg)
	m.SetBody(e.RootFullBody1, e.RootFullBody2)
	
	d := gomail.NewDialer(e.SMTPServer, e.SMTPPort, e.NoReplyAcct, pw)

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
		sendRootFullEmail(pw)
	}
}
