// stuff
package acronym

import "regexp"

/*import "fmt"*/
import "strings"

func Abbreviate(s string) string {

	/*
		acro := ""*/
	/*r, _ := regexp.Compile(`\b[A-z]{1,1}`) */ // <3 this KISS method
	re := regexp.MustCompile(`\b[A-z]{1}`)
	/*fmt.Println(re.FindAllString(s, -1))*/

	stringArray := re.FindAllString(s, -1)
	justString := strings.Join(stringArray, "")

	/* fmt.Println(justString)*/
	/* input := re.FindAllString(s, -1)

	       re_leadclose_whtsp := regexp.MustCompile(`^[\s\p{Zs}]+|[\s\p{Zs}]+$`)
	   re_inside_whtsp := regexp.MustCompile(`[\s\p{Zs}]{1,}`)

	   final := re_leadclose_whtsp.ReplaceAllString(input, "")
	   final = re_inside_whtsp.ReplaceAllString(final, "")
	       fmt.Println(final)*/

	return strings.ToUpper(justString)
}
