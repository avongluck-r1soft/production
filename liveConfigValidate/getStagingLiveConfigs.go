package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

var stagingCsbms = []string{
	"678986ba-02c6-4eb7-9928-7d657714f84c","3fd0a148-d797-4046-8e86-167b2e6f3606","cf955142-42c7-4c75-936e-c41af8085e3c",
	"b1af613f-35a7-49b4-88bc-b5c0f22c120b","c36d175f-3415-40ae-93a0-2c1cb3158cac","95378d6d-d842-48d5-8a1e-050859a7c30e",
	"a7a74a6f-9143-4f52-8153-ccaf9327bb66","8b7ba07c-4f73-45dd-847e-553839096446","677cec42-5a6d-4653-87d6-7f266b4e9c7e",
	"9d1ff06b-729e-48d5-91a3-64be34df79a8",
}

func getLiveConfig(csbm string) string {
	res, err := http.Get("http://10.80.65.31:57988/r1rmHouston/csbm/" + csbm + "/liveConfig")
	if err != nil {
		fmt.Printf("Unable to access proxy host: %s", err)
	}

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		fmt.Printf("Unable to read response body: %s", err)
	}

	res.Body.Close()
	return fmt.Sprintf("%s", body)
}

func main() {
	numsbms := 0
	fmt.Printf("\nStaging csbms:\n")
	for i := range stagingCsbms {
		data, err := json.MarshalIndent(getLiveConfig(stagingCsbms[i]), "", "	")
		if err != nil {
			fmt.Println("Error marshalling liveconfig string", err.Error())
		}

		fmt.Printf("\n\n%s\n%s", stagingCsbms[i], data)
		numsbms++
	}
	fmt.Printf("Total sbms: %d\n", numsbms)
}
