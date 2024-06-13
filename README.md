![ss24-01-31-175854](https://github.com/sephid86/fulleaf/assets/77107998/80d2117e-f617-4ab1-8634-5603873e92ba)

최근 업데이트 2024년 06월 24일 <br>
<br>
풀잎 리눅스 - (Fulleaf Linux) <br>
--
이곳의 파일들은 풀잎 리눅스의 다음 업데이트에 사용될 테스트 파일들 입니다.
<br>
<br>

풀잎 리눅스 배포판은 아래 링크에서 다운로드 받으실수 있습니다.<br>
--
https://drive.google.com/file/d/1OH5wYBH6tEeJzI2UUjvILuaMHZVchkcw/view?usp=drive_link
<br>

풀잎 리눅스를 가상머신에 설치하는 경우 
-
1. 가상머신을 efi 로 설정 해줘야 합니다.<br>

ranger 이미지 미리보기
-
foot 터미널 기준입니다.

1. aur 에서 ranger-git 설치해줍니다.

2. ~/.config/ranger/rc.conf 파일에서
아래 내용 주석 풀어줍니다.
set preview_images_method sixel

