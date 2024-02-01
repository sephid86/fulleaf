![ss24-01-31-175854](https://github.com/sephid86/fulleaf/assets/77107998/80d2117e-f617-4ab1-8634-5603873e92ba)

풀잎 리눅스 - (Fulleaf Linux)
--
이곳의 파일들은 풀잎 리눅스의 다음 업데이트에 사용될 테스트 파일들 입니다.

풀잎 리눅스 배포판은 아래 링크에서 다운로드 받으실수 있습니다.
--
https://drive.google.com/file/d/1t4NCmIA0jRldBdLeCMnNcBpzca-cj2vB/view?usp=drive_link
<br>

-
스웨이(Sway) 에서는 한글입력기를 직접 설정 하셔야 합니다.<br>
풀잎 리눅스에서 스웨이의 한글입력기를 기본 설치에서 제외한 이유는 두가지 입니다.
1. kime 을 기본 입력기로 설정했었으나 컴파일 과정으로 설치 시간이 길어지는 점.<br>
2. 스웨이 사용자는 어느정도 리눅스에 대한 이해도가 있는
숙련자일 확률이 많으므로 기본 입력기가 거슬릴수 있는점.<br>
-

풀잎 리눅스를 가상머신에 설치하는 경우 
-
1. 가상머신을 efi 로 설정 해줘야 합니다.<br>

2. 가상머신에서 sway 를 정상적으로 사용하는 방법은 구글 검색 바랍니다.<br>

ranger 이용시
-
1. ranger 에서 rename 버그는 aur 의 ranger-git 을 설치해야 정상 작동 합니다.<br>
관련 내용은 아래 링크를 확인해주시기 바랍니다.<br>
https://github.com/ranger/ranger/issues/2864<br>

2. ranger 이용시 chmod +x /home/사용자ID/.config/ranger/scope.sh 해줘야 합니다.<br>
깜빡잊고 빠트렸습니다. 다음 버전 업데이트에 수정하겠습니다.<br>
<br>
