## BabyRE

**Kiểm tra file**
![alt](https://github.com/dtuananh/Practice-Assembly/blob/main/RE/week1/BabyRE/kiemtra.png)

Ta có thể thấy đây là 1 file PE32

**Chạy thử**
![alt](https://github.com/dtuananh/Practice-Assembly/blob/main/RE/week1/BabyRE/chaythu.png)

Có thể thấy chương trình yêu cầu chúng ta nhập đầu vào là key sau đó trả về kết quả là flag. 
Mình có thử nhập một vài testcase thì thấy chương trình nhận đầu vào là năm số để làm key giải mã.

**Phân tích file**
![alt](https://github.com/dtuananh/Practice-Assembly/blob/main/RE/week1/BabyRE/ida1.png)

Sử dụng IDA Pro để phân tích file
Nhấn `F5` để có được code như hình trên.

Đọc qua một lượt ta có thể thấy các biến `v8`, `v9`, `v10`, `v11` lưu một chuỗi ký tự chính là flag đã được mã hóa

Tiếp theo đó là đoạn code để lấy đầu vào là 5 ký tự có kích thước là 1 byte
```C
for ( i = 0; i < 5; ++i )
    scanf("%hhd", &v12[i]);
```

Cuối cùng là một đoạn code khác sử dụng các biến như `v8`, `v12` để xử lý tính toán để in ra flag
```C
for ( j = 0; j < 26; j += 2 )
  {
    v5 = (char *)&v8 + j;
    *v5 ^= v12[j % 5u];
    v6 = j;
    v5[1] ^= v12[v6 - 5 * ((unsigned int)&v5[1 - (_DWORD)&v8] / 5) + 1];
  } 
  printf("flag is : %s\n", (const char *)&v8);
```

**Solution**

![alt](https://github.com/dtuananh/Practice-Assembly/blob/main/RE/week1/BabyRE/ida2.png)

Ta sẽ sửa lại code một chút cho dễ nhìn hơn

Nhìn vào đoạn code được sử dụng để giải mã `cipherText` nhận thấy:
Với mỗi bước nhảy thuật toán này sẽ xử lý 2 byte dữ liệu của `cipherText`:
    + Byte đầu tiên sẽ được `xor` với `key[j % 5]`
    + Byte kế tiếp sẽ được `xor` với `key[v6 - 5 * ((unsigned int)&tmp[1 - (_DWORD)cipherText] / 5) + 1]`; với đoạn này ta có thể viết lại thành `cipherText[j - 5 * ((j + 1) / 5) + 1]`

Cuối cùng công việc của ta là sử dụng lại đoạn code này cùng với flagForm `flag{` đã cho sẵn để tính key chương trình yêu cầu
Sau đây là script mình dùng để tính key:

```C
#include <stdio.h>

char cipherText[] = "bdnpQai|nufimnug`n{Fafhr\0";
char flagForm[] = "flag{";

int key[] = {};

int main ()
{
    for (int i = 0; i < 26; i += 2)
    {
        char tmp = cipherText[i];
        tmp ^= flagForm[i % 5];
        char tmp2 = cipherText[i+1];
        tmp2 ^= flagForm[i - 5 * ((i + 1) / 5) + 1];
        key[i] = tmp;
        key[i+1] = tmp2;
    }

    for (int i = 0; i < 5; i++)
    {
        printf("%d  ", key[i]);
    }

    return 0;
}
```

**Kết quả**

![alt](https://github.com/dtuananh/Practice-Assembly/blob/main/RE/week1/BabyRE/ketqua.png)

Flag:   `flag{easy_baby_challenge}`