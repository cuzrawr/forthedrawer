

################################################################################
# v0.8rc2 ( dhcp-client only ) on Sun, Sep 20, 2020
#                       _____  _____  __     _____  ____
#                      |  |  ||  _  ||  |   |   __||    \
#                      |     ||     ||  |__ |   __||  |  |
#                      |__|__||__|__||_____||__|   |____/
#                      high accuracy lose|failure detector
#
#                          -=[ Short description ]=-
#
# Wrote this script because ALOT of pain with bare netwatch.
# There also some weird things but we are just a script. You are warned.
#
# When netwatch rekt, we do some magic in down part:
#     Disable self for preventing rerun.
#     Than checks every iterate if there were ping losses and
#     act accordind getted result, if none we return back to netwatch.
#
#                 -=[ Main requirements and recomendations ]=-
#
# Need custom dhcp-client with comment "ISP1".
# Adjust "stockDistance" and "thresholdPercent" for your needs.
# "thresholdPercent" below 5 may cause inaccuracy.
# "stockDistance" need to be less than your secondary ISP distance.
# Don't change default-route-distance directly in dhcp-client.
# #
# Add blackhole routes to monitored IPs to avoid checks through secondary ISP.
# Obviously monitored IPs nailed to ISP1.
# Set ICMP packets to HIGHEST priority.
# For best results netwatch interval can be set to "00:00:01" or "00:00:05".
# !!! ALL connections on failover will reset. You can improve this.
#
################################################################################






#
# postsetup ( part of failover script )
#

/system scheduler
add name=HLTCHKSCHD on-event=":delay 60s\r\
    \n:log warning \"[ ! ] verifying netwatch HLTCHK script\"\r\
    \n#if ([/system script job find where owner~\"sys\"] = \"\") do={\r\
    \n\t/tool netwatch enable [ find comment=\"HLTCHK\" and status!=up ];\r\
    \n#};" policy=reboot,read,write,test start-time=startup

#
/ip route add distance=250 dst-address=8.8.4.4 type=blackhole comment="ISP1DONOTDELETE"
/ip route add distance=250 dst-address=1.0.0.1 type=blackhole comment="ISP1DONOTDELETE"








#
# dhcp-client -> advanced ( part of failover script )
#
:local defDistance [/ip dhcp-client get [find where comment="ISP1"] default-route-distance];
if ($bound=1) do={
	if ( [/ip route find where comment="ISP1HEALTHDST"] = "") do={
	 	/ip route add dst-address=1.0.0.1 gateway=$"gateway-address" scope=10 comment="ISP1HEALTHDST" distance=$defDistance;
		/ip route add dst-address=8.8.4.4 gateway=$"gateway-address" scope=10 comment="ISP1HEALTHDST" distance=$defDistance;
	};
} else={
	/ip route remove [find comment="ISP1HEALTHDST"];
};






#
# netwatch -> down ( part of failover script )
#
/tool netwatch disable [ find comment="HLTCHK" ];
:log warning message=("[ ! ] netwatch host timeout");

# accuracy threshold ( lower = better )
:local thresholdPercent 5;
# must be equal to default-route-distance ( on dhcp-client )
:local stockDistance 1;

#
:local lossPercentage;
:local lossPercentageFunc do={:return  (100 - [ /ping count=100 interval=100ms size=28 8.8.4.4 ])};
:local newgw;
:local curgw;

# delay execution (avoid most link flaps)
:delay 5s;

# main loop
do {

	# if this script up that ambiguous
	if ([ /tool netwatch find where comment="HLTCHK" and status=up ]) do={
		:log error message="[ e ] netwatch already up ";
		:delay 5s;
		:return 0;
	};

	# no sense if dhcp-client disabled
	if ([/ip dhcp-client find where comment="ISP1" and disabled=yes]) do={
		:log error message="[ e ] dhcp-client disabled. ";
		:delay 1m;
		/tool netwatch enable [ find comment="HLTCHK" ];
		:return 0;
	};

	# no sense if interface fall
	if ([/interface ethernet get [/ip dhcp-client get [find where comment="ISP1"] interface ] running ] = false) do={
		:log error message="[ e ] interface not running. ";
		:delay 1m;
		/tool netwatch enable [ find comment="HLTCHK" ];
		:return 0;
	};

	# no sense if route to the checked host disappeared
	if ([/ip route find where comment="ISP1HEALTHDST"] = "") do={
		:log error message="[ e ] route to test hosts gone. ";
		:delay 1m;
		/tool netwatch enable [ find comment="HLTCHK" ];
		:return 0;
	};

	# somethimes ISP change their GW
	:set newgw [/ip dhcp-client get [find where comment="ISP1"] gateway];
	:set curgw [/ip route get [find where comment="ISP1HEALTHDST" and dst-address="1.0.0.1/32" ] gateway ];
	if ($newgw != $curgw) do={
		:log warning message="[ ! ] updating health hosts gw";
		/ip route set [find comment="ISP1HEALTHDST"] gateway=$newgw;
	};

	:set lossPercentage [:put [$lossPercentageFunc]];

	if ( [ $lossPercentage ] >=  $thresholdPercent  )  do={
			#
			if ([ /ip dhcp-client find where comment="ISP1" and default-route-distance!=25 ]) do={

				/ip dhcp-client set [find where comment="ISP1"] default-route-distance=25;
				# resseting all connections. improve this
				/ip firewall connection remove [find];
				#
				:log warning message="[ ! ] fallback to secondary ISP";
			};

			:log info message=("[ * ] approx pkt loss: " . $lossPercentage . "%");

	} else={
		if ([ $lossPercentage ] <  $thresholdPercent) do={
			:log info message="[ * ] approx pkt loss below threshold ";
			#
			# check if we already have ISP1 with distance other than 1
			if ([ /ip dhcp-client find where comment="ISP1" and default-route-distance!=1 ]) do={
				:log warning message="[ ! ] reverted to primary ISP";
				# setting distance back
				/ip dhcp-client set [find where comment="ISP1"] default-route-distance=$stockDistance;
				# resseting all connections. improve this
				/ip firewall connection remove [find];
			};

			# and enable self
			/tool netwatch enable number=[find comment="HLTCHK"];
		};
	};
} while=( $lossPercentage  >= $thresholdPercent  ) on-error={
														# reverting back distance param
														if ([ /ip dhcp-client find where comment="ISP1" and default-route-distance!=1 ]) do={
															/ip dhcp-client set [find where comment="ISP1"] default-route-distance=$stockDistance;
														}

														:delay 10s

														#
														/tool netwatch enable [ find comment="HLTCHK" and status!=up ]

														:log error message="error in main loop"

														# quit script
														:error message="quit"
													};
#
#
# ISP failover script EOF


################################################################################
