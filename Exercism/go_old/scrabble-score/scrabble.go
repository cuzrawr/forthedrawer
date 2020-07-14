package scrabble

/*import "regexp"*/
import "strings"

func Score(s string) int {

	sub := 0
	s = strings.ToUpper(s)

for i := 0; i < len(s); i++ {
	//
	//
	//

	if strings.ContainsAny(string(s[i]), "A & E & I & O & U & L & N & R & S & T") == true {
		sub += 1
	}
	if strings.ContainsAny(string(s[i]), "D & G") == true {
		sub += 2
	}
	if strings.ContainsAny(string(s[i]), "B & C & M & P") == true {
		sub += 3
	}
	if strings.ContainsAny(string(s[i]), "F & H & V & W & Y") == true {
		sub += 4
	}
	if strings.ContainsAny(string(s[i]), "K") == true {
		sub += 5
	}
	if strings.ContainsAny(string(s[i]), "J & X") == true {
		sub += 8
	}
	if strings.ContainsAny(string(s[i]), "Q & Z") == true {
		sub += 10
	}
}

return sub


/*	finished := 0

for i := 0; i < len(s); i++ {

	if IsAEIOULNRST(s) == true {
		finished++
	}
	if IsDG(s) == true {
		finished += 2
	}
	if IsBCMP(s) == true {
		finished += 3
	}
	if IsFHVWY(s) == true {
		finished += 4
	}
		if IsK(s) == true {
		finished += 5
	}
	if IsJX(s) == true {
		finished += 8
	}
	if IsQZ(s) == true {
		finished += 10
	}

}
return finished*/
}
