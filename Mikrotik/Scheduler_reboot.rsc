/system scheduler add comment=Schedule_reboot_router interval=1w name=REBOOTSCHD on-event="#\r\
    \n# We definetly dont wanna shoot ourself in the foot.\r\
    \n#\r\
    \n\r\
    \nif ( [/system resource get uptime ] < [:totime \"6d23h59m10s\" ] ) do={\r\
    \n\t:log warning \"Less than 7 days. Cannot reboot router\"\r\
    \n} else={\r\
    \n\t:log info \"Reboot ...\"\r\
    \n\t/system reboot\r\
    \n};" policy=reboot,read,test start-date=sep/03/2021 start-time=00:00:00
