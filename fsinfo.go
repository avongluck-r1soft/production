package main

import (
	"fmt"
    "log"
	"syscall"
    "gopkg.in/gomail.v2"
)

type DiskStatus struct {

	All  uint64 `json: "all"`
	Used uint64 `json: "used"`
	Free uint64 `json: "free"`

}

//func DiskUsage(path string) (disk DiskStatus) {
func DiskUsage(path string) (disk DiskStatus) {

	fs  := syscall.Statfs_t{}
	err := syscall.Statfs(path, &fs)

	if err != nil {
		return
	}

	disk.All  = fs.Blocks * uint64(fs.Bsize)
	disk.Free = fs.Bfree  * uint64(fs.Bsize)
	disk.Used = disk.All - disk.Free

	fmt.Printf("used:\t %.2f GB\n", (float64(disk.Used)/1024/1024/1024))
    return
}

func main() {

    threshhold := 

    // sbjenkins-root is /
	disk := DiskUsage("/")

	fmt.Printf("free:\t %.2f%% \n", float64(disk.Used) / float64(disk.Free) * 100.0)

    m := gomail.NewMessage()
    m.SetHeader("From", "scott.gillespie@r1soft.com")
    m.SetHeader("To", "scott.gillespie@r1soft.com")
    m.SetHeader("Subject", "SBJENKINS SHITTER'S FULL!")
    m.SetBody("text/html", "jenkins-root SHITTER'S FULL!")

    d := gomail.NewDialer("smtp.office365.com", 587, "scott.gillespie@r1soft.com", "")

    err := d.DialAndSend(m)

    if err != nil {
        log.Fatal(err)
    }

}
