package hamming

import (
	"errors"
	/*"fmt"*/ /*"strings"*/)

func Distance(a, b string) (int, error) {
	err := errors.New("Invalid compare data")
	/*	strings.Split(a, "")
		strings.Split(b, "")

		for _, e := len(a) {
			x := strings.SplitN(a, "", len(_))
			for _, p := len(b) {
				m := strings.SplitN(b, "", len(_))

			}
		}*/
	eo := 0
	/*temp := strings.Split(a, "")*/

	if len(a) == len(b) {
		for i := 0; i < len(a); i++ {
			if int(a[i]^b[i]) != 0 {
				eo++
			}
		}
		/*for _, v := range temp {
		xor := int(a[v] ^ b[v])
			if xor != 0 {
				eo++
			}

		}*/
		return int(eo), nil

	} else {
		return int(-1), err
	}
}
