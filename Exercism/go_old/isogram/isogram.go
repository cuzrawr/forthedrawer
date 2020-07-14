package isogram

import "strings"

func IsIsogram(s string) bool {
	exists := true
	// strings magic
	s = strings.ToUpper(s)
	s = strings.Replace(s, "-", "", -1)
	s = strings.Replace(s, " ", "", -1)

	for i := 0; i < len(s); i++ {
        // Scan slice for a previous element of the same value.
        for v := 0; v < i; v++ {
            if s[v] == s[i] {
                exists = false
                break
            }
        }
    }
	return exists
}
