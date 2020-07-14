// fuck this shit i want quit in windows now
package bob

import "regexp"

func Hey(remark string) string {

	//debug


	answer := "Whatever."
//[A-Z \s\d\W]*[A-Z \s\d\W].\!|^[A-Z \s]*[A-Z \s]$
	//^(![A-Z])|([A-Z]{3,4}.[A-Z\s])
	reQuestion  := regexp.MustCompile(`[a-z].+\s*[A-z \d\W]\?$|\s.[0-9]\?$|^\d\?$|^\W+\?$|\?\s+$`) //for Sure.
	reChill     := regexp.MustCompile(`^(![A-Z])|([A-Z]{3,4}.[A-Z\s])|^\d.+\!$`)  //for Whoa, chill out!'
    reChillbobs := regexp.MustCompile(`([A-Z]{3,4})\?$`)    //for Calm down, I know what I'm doing!
   	reHey       := regexp.MustCompile(`^+\s+$|^$`)    //for Fine. Be that way!


   	if reQuestion.FindStringSubmatch(remark) != nil {
   		answer = "Sure."
   	} else if reChillbobs.FindStringSubmatch(remark) != nil {
   		answer = "Calm down, I know what I'm doing!"
   	} else if reChill.FindStringSubmatch(remark) != nil {
   		answer = "Whoa, chill out!"
   	} else if reHey.FindStringSubmatch(remark) != nil {
   		answer = "Fine. Be that way!"
   	}
   	//for else Whatever.
	// Write some code here to pass the test suite.
	// Then remove all the stock comments.
	// They're here to help you get started but they only clutter a finished solution.
	// If you leave them in, reviewers may protest!
	return answer
}
