#!/usr/bin/perl -w
#TODO:多次执行AGI时候的问题
use strict;
use IO::Socket;
use 5.010;
$| = 1;
my $socket = IO::Socket::INET->new(
    PeerAddr => '127.0.0.1',
    PeerPort => 4573,
    Proto    => "tcp",
    Timeout  => 3,
    Type     => SOCK_STREAM
) or die "Couldn't connect to : $@\n";

$socket->autoflush(1);

my %agi_param = (

    #请求的脚本文件名
    agi_request => 'agi://127.0.0.1/demo',

    #The originating channel (your phone)
    agi_channel  => 'SIP/8001-00000001',
    agi_language => 'en',

    #当前通道类别(e.g. "SIP" or "ZAP")
    agi_type => 'SIP',

    #A unique ID for the call
    agi_uniqueid => 'freeiris2-1275705995.0',

    #Asterisk版本 (1.6)
    agi_version => '1.0',

    #The caller ID number (or "unknown")
    agi_callerid => '8001',

    #The caller ID name (or "unknown")
    agi_calleridname => '8001',

    #The presentation for the callerid in a ZAP channel
    agi_callingpres => '0',

#The number which is defined in ANI2 see Asterisk Detailed Variable List (only for PRI Channels)
    agi_callingani2 => '0',

    #The type of number used in PRI Channels see Asterisk Detailed Variable List
    agi_callington => '0',

#An optional 4 digit number (Transit Network Selector) used in PRI Channels see Asterisk Detailed Variable List
    agi_callingtns => '0',

    #The dialed number id (or "unknown")
    agi_dnid => '8002',

    #The referring DNIS number (or "unknown")
    agi_rdnis => 'unknown',

    #Origin context in extensions.conf
    agi_context => 'from-exten-sip',

    #The called number
    agi_extension => '200',

    #The priority it was executed as in the dial plan
    agi_priority => '1',

    #The flag value is 1.0 if started as an EAGI script, 0.0 otherwise
    agi_enhanced => '0.0',

    #Account code of the origin channe
    agi_accountcode => '8001',

    #执行该AGI脚本的线程ID (1.6)
    agi_threadid => '3021',

    agi_network => 'yes',

    agi_network_script => '',
);

#从服务端获取的AGI变量信息
my %get_agi_param = ( 'CDR(uniqueid)' => $agi_param{'agi_uniqueid'} );

my $EOF = "\012";
send_agi();

#only for win ?
#$socket->blocking(1);
#while ( $socket->recv( my $message, 1000 ) ) {
#        print $message . "\r\n";
#		if ( $message =~ /^GET VARIABLE (.*)/ ){
#			 if ( $get_agi_param{$1} ){
#		          $socket->send( "200 result=1 ($get_agi_param{$1})");
#			 }
#			 else{$socket->send( "200 result=0");}
#
#			 $socket->send($EOF);
#		}
#		#设置变量EXEC set "FRI2_SESSIONID=1275706269282392"
#		elsif ( $message =~ /^EXEC set \"(.*)=(.*)\"/ ){
#		       #print $1,$2 . "\n";
#				$get_agi_param{$1} = $2;
#				$socket->send( "200 result=0" );
#		        $socket->send($EOF);
#
#		}
#		else {$socket->send( "200 result=0" );
#		      $socket->send($EOF);}
#
#}

#only this linux and win can work fine;
while ( my $message = <$socket> ) {
    say '[DEBUG] FROM AGISPEEDY:'. $message;
    if ( $message =~ /^GET (.*)/ ) {
        if ( $get_agi_param{$1} ) {
            $socket->send("200 result=1 ($get_agi_param{$1})");
        }
        else {
            my $get = get_input($1);
            if ($get) {
                $socket->send("200 result=1 ($get)");
            }else{
                $socket->send("200 result=0");
            }
            }

        $socket->send($EOF);
    }

    #设置变量EXEC set "FRI2_SESSIONID=1275706269282392"
    elsif ( $message =~ /^EXEC set \"(.*)=(.*)\"/ ) {

        #print $1,$2 . "\n";
        $get_agi_param{$1} = $2;
        $socket->send("200 result=0");
        $socket->send($EOF);

    }
    else {
        $socket->send("200 result=0");
        $socket->send($EOF);
    }
    say '#' x 50;

}
$socket->close;

print '#' x 50 . "\r\n";
say '[DEBUG]param dump:';
dump_get_agi_param();

sub send_agi {
    foreach ( keys %agi_param ) {
        print $_ . ": " . $agi_param{$_} . $EOF;
        $socket->send( $_ . ": " . $agi_param{$_} );
        $socket->send($EOF);
    }
    $socket->send($EOF);
    print '#' x 50 . "\r\n";
}

sub dump_get_agi_param {
    foreach ( keys %get_agi_param ) {
        print $_ . ": " . $get_agi_param{$_} . "\r\n";
    }
}

sub get_input{
    my $titel = shift;
    say '[DEBUG] TO AGISPEEDY: Set Value ' . $titel;
    my $input = <STDIN>;
    chomp($input);
    return $input;
}

exit;