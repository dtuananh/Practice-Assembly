.386
.model	flat, stdcall
option	casemap:none

include windows.inc
include kernel32.inc 
include user32.inc 


NULL EQU  0
MAXBUF EQU 255
.data
	inputLog	db	"Executable Files 32-bit (*.exe, *.dll): ", 0
	errorLog	db	0Ah, "Could not read file!", 0Ah, 0Dh, 0
	white_space db	"	", 0
	endl		db	0Ah, 0Dh, 0

	;IMAGE_DOS_HEADER
	DosHeader	db	0Ah, 0Ah, "******* DOS HEADER *******", 0Ah, 0
	e_magic		db	"		Magic number", 0Ah, 0
	e_cblp		db	"		Byte on last page offset file", 0Ah, 0
	e_cp		db	"		Page in file", 0Ah, 0
	e_crl		db	"		Relocations", 0Ah, 0
	e_cparhdr	db	"		Size offset header in paragraphs", 0Ah, 0
	e_minalloc	db	"		Minimum extra paragraphs needed", 0Ah, 0
	e_maxalloc	db	"		Maximum extra paragraphs needed", 0Ah, 0
	e_ss		db	"		Initial (relative) SS value", 0Ah, 0
	e_sp		db	"		Initial SP value", 0Ah, 0
	e_csum		db	"		Checksum", 0Ah, 0
	e_ip		db	"		Initial IP value", 0Ah, 0
	e_cs		db	"		Initial (relative) CS value", 0Ah, 0
	e_lfarlc	db	"		File address of relocation table", 0Ah, 0
	e_ovno		db	"		Overlay number", 0Ah, 0
	e_oemid		db	"		OEM identifier (for e_oeminfo)", 0Ah, 0
	e_oeminfo	db	"		OEM information; e_oemid specific", 0Ah, 0
	e_lfanew	db	"		File address of new exe header", 0Ah, 0


	;IMAGE_NT_HEADER
	NtHeader	db	0Ah, 0Ah, "******* NT HEADERS *******", 0Ah, 0
	Signature	db	"		Signature", 0Ah, 0

	;FILE_HEADER
	FileHeader			db  0Ah, 0Ah, "******* FILE HEADER *******", 0Ah, 0
	Machine				db  "		Machine", 0Ah, 0
    NumOfSections		db  "		Number Of Sections", 0Ah, 0
    TimeDateStamp		db  "	Time Date Stamp", 0Ah, 0
    PointerToSymbolTable db  "		Pointer to Symbol Table", 0Ah, 0
    NumberOfSymbols		db  "		Number of Symbols", 0Ah, 0
    SizeOfOptionalHeader db  "		Size of Optional Header", 0Ah, 0
    Characteristics		db  "		Characteristics", 0Ah, 0

	;OPTIONAL_HEADER
	OptionalHeader  db  0Ah, 0Ah, "******* OPTIONAL HEADER *******", 0Ah, 0
    Magic           db  "		Magic", 0Ah, 0
    MajorLinkerVer  db  "		Major Linker Version", 0Ah, 0
    MinorLinkerVer  db  "		Minor Linker Version", 0Ah, 0
    SizeOfCode      db  "		Size Of Code", 0Ah, 0
    SzOfInitData    db  "		Size Of Initialized Data", 0Ah, 0
    SzOfUninitData  db  "		Size Of UnInitialized Data", 0Ah, 0
    AddressOfEntry  db  "		Address Of Entry Point (.text)", 0Ah, 0
    BaseOfCode      db  "		Base Of Code", 0Ah, 0
	BaseOfData      db  "		Base Of Data", 0Ah, 0
    ImageBase       db  "	Image Base", 0Ah, 0
    SectionAlign    db  "		Section Alignment", 0Ah, 0
    FileAlign       db  "		File Alignment", 0Ah, 0
    MajorOSVer      db  "		Major Operating System Version", 0Ah, 0
    MinorOSVer      db  "		Minor Operating System Version", 0Ah, 0
    MajorImageVer   db  "		Major Image Version", 0Ah, 0
    MinorImageVer   db  "		Minor Image Version", 0Ah, 0
    MajorSubsysVer  db  "		Major Subsystem Version", 0Ah, 0
    MinorSubsysVer  db  "		Minor Subsystem Version", 0Ah, 0
    Win32Version    db  "		Win32 Version Value", 0Ah, 0
    SizeOfImage     db  "		Size Of Image", 0Ah, 0
    SizeOfHeaders   db  "		Size Of Headers", 0Ah, 0
    CheckSum        db  "		CheckSum", 0Ah, 0
    Subsystem       db  "		Subsystem", 0Ah, 0
    DllCharacter    db  "		DllCharacteristics", 0Ah, 0
    SizeOfStackRes  db  "		Size Of Stack Reserve", 0Ah, 0
    SizeOfStackCom  db  "		Size Of Stack Commit", 0Ah, 0
    SizeOfHeapRes   db  "		Size Of Heap Reserve", 0Ah, 0
    SizeOfHeapCom   db  "		Size Of Heap Commit", 0Ah, 0
    LoaderFlags     db  "		Loader Flags", 0Ah, 0
    NumberOfRvaAndS db  "		Number Of RVA And Sizes", 0Ah, 0

	;DATA_DIRECTORIES
	DataDirectories	db	0Ah, 0Ah, "******* DATA DIRECTORIES *******", 0
    ExportDir		db	0Ah, "Export Directory Address:	", 0
	ImportDir		db	0Ah, "Import Directory Address:	", 0
	Sz			db	";		Size:	", 0

	;SECTION_HEADERS
	SectionHeader			db	0Ah, 0Ah, 0Ah, "******* SECTION HEADERS *******", 0Ah, 0
	VirtualSize		        db  "		Virtual Size", 0Ah, 0
    VirtualAddress			db  "		Virtual Address", 0Ah, 0
    SizeOfRawData           db  "		Size of Raw Data", 0Ah, 0
    PointerToRawData        db  "		Pointer to Raw Data", 0Ah, 0
    PointerToRelocation     db  "		Pointer to Relocs", 0Ah, 0
    PointerToLinenumbers    db  "		Pointer to Line Numbers", 0Ah, 0
    NumberOfRelocations     db  "		Number of Relocs", 0Ah, 0
    NumberOfLinenumbers     db  "		Number of Line Numbers", 0Ah, 0
    Characteristics_sec     db  "	Characteristics", 0Ah, 0

	;EXPORT_DIRECTORY
	ExportDirectory		db	0Ah, 0Ah, "******* EXPORT DIRECTORY *******", 0Ah, 0

	;IMPORT_DIRECTORY
	ImportDirectory		db	0Ah, 0Ah, "******* IMPORT DIRECTORY *******", 0Ah, 0
	Ordinal				db	"Ordinal: ", 0


.data?
	lpFileName db MAXBUF DUP(?)	

	hInput HANDLE ?
	hOutput HANDLE ?
	
	hFile HANDLE ?
	lpFileSize dd ?
	lpFileBuffer dd ?
	lpBufferAddress dd ?
	bRead dd ?

	hex db MAXBUF DUP(?)

	sectionSize dd ?
	sectionLocation dd ?
	importRVA dd ?
	exportRVA dd ?

	numberOfFunctions dd ?


.code
main proc
	call GetHandle	
	
	push offset inputLog
	call WriteString
	push offset lpFileName
	call ReadString

	;open file
	push NULL					;hTemplateFile = NULL
	push FILE_ATTRIBUTE_NORMAL	;dwFlagsAndAttributes = FILE_ATTRIBUTE_NORMAL
	push OPEN_EXISTING			;dwCreationDisposition = OPEN_EXISTING
	push NULL					;lpSecurityAttributes = NULL
	push FILE_SHARE_READ		;dwShareMode = FILE_SHARE_READ
	push GENERIC_READ			;dwDesiredAccess = GENERIC_READ
	push offset lpFileName		;lpFileName
	call CreateFileA	
	cmp eax, -1		;if  hFile == -1 => print errorLog
	jz error
	mov hFile, eax

	;allocate heap
	push offset lpFileSize			;lpFileSizeHigh
	push hFile				;hFile
	call GetFileSizeEx
	call GetProcessHeap
	push lpFileSize			;dwBytes
	push HEAP_ZERO_MEMORY	;dwFlags = HEAP_ZERO_MEMORY
	push eax				;hHeap
	call HeapAlloc
	mov lpFileBuffer, eax
	
	mov lpBufferAddress, eax		;save address of lpFileBuffer 

	;read file bytes to memory
	push NULL				;lpOverlapped
	push offset bRead		;lpNumberOfBytesRead
	push lpFileSize			;nNumberOfBytesToRead
	push lpFileBuffer		;lpBuffer
	push hFile				;hFile
	call ReadFile


;DOS_HEADER
	push offset DosHeader
	call WriteString
	mov eax, lpFileBuffer
	movzx ecx, word ptr [eax]
	cmp ecx, 5A4Dh				;dos magic number
	jnz error
	
	;e_magic
	push offset white_space
	call WriteString
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_magic
	call WriteString

	;e_cblp
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_cblp
	call WriteString

	;e_cp
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_cp
	call WriteString

	;e_crl
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_crl
	call WriteString

	;e_cparhdr
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_cparhdr
	call WriteString

	;e_minalloc
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_minalloc
	call WriteString

	;e_maxalloc
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_maxalloc
	call WriteString

	;e_ss
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_ss
	call WriteString

	;e_sp
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_sp
	call WriteString

	;e_csum
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_csum
	call WriteString

	;e_ip
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_ip
	call WriteString

	;e_cs
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_cs
	call WriteString

	;e_lfarlc
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_lfarlc
	call WriteString

	;e_ovno
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_ovno
	call WriteString

	;e_oemid
	push offset white_space
	call WriteString
	add lpFileBuffer, 10
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex	
	push offset e_oemid
	call WriteString

	;e_oeminfo
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset e_oeminfo
	call WriteString

	;e_lfanew
	push offset white_space
	call WriteString
	add lpFileBuffer, 16h
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	mov e_fileAddress, edi
	call WriteHex
	push offset e_lfanew
	call WriteString


;NT_HEADERS
	push offset NtHeader
	call WriteString
	mov eax, lpFileBuffer
	;calc value of signature
	sub lpFileBuffer, 03Ch
	mov edx, dword ptr [eax]
	add lpFileBuffer, edx
	;print
	push offset white_space
	call WriteString
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset Signature
	call WriteString


;FILE_HEADER
	push offset FileHeader
	call WriteString

	;Machine
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset Machine
	call WriteString

	;Number Of Sections
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	mov sectionSize, edi			;save the number of section
	call WriteHex
	push offset NumOfSections
	call WriteString

	;Time Date Stamp
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset TimeDateStamp
	call WriteString

	;Pointer to Symbol Table
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset PointerToSymbolTable
	call WriteString

	;Number of Symbols
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset NumberOfSymbols
	call WriteString

	;Size of Optional Header
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
			;get section header offset
	mov sectionLocation, edi
	add sectionLocation, eax
	add sectionLocation, 4
	call WriteHex
	push offset SizeOfOptionalHeader
	call WriteString

	;Characteristics
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset Characteristics
	call WriteString


;OPTIONAL_HEADER
	push offset OptionalHeader
	call WriteString

	;Magic
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset Magic
	call WriteString

	;Major Linker Version
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, byte ptr [eax]
	call WriteHex
	push offset MajorLinkerVer
	call WriteString

	;Minor Linker Version
	push offset white_space
	call WriteString
	add lpFileBuffer, 1
	mov eax, lpFileBuffer
	movzx edi, byte ptr [eax]
	call WriteHex
	push offset MinorLinkerVer
	call WriteString

	;Size Of Code
	push offset white_space
	call WriteString
	add lpFileBuffer, 1
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SizeOfCode
	call WriteString

	;Size Of Initialized Data
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SzOfInitData
	call WriteString

	;Size Of Unintialized Data
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SzOfUninitData
	call WriteString

	;Address Of Entry Point (.text)
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset AddressOfEntry
	call WriteString

	;Base Of Code
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset BaseOfCode
	call WriteString

	;Base Of Data
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset BaseOfData
	call WriteString

	;Image Base
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset ImageBase
	call WriteString

	;Section Alignment
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SectionAlign
	call WriteString

	;File Alignment
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset FileAlign
	call WriteString

	;Major Operating System Version
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset MajorOSVer
	call WriteString

	;Minor Operating System Version
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset MinorOSVer
	call WriteString

	;Major Image Version
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset MajorImageVer
	call WriteString

	;Minor Image Version
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset MinorImageVer
	call WriteString

	;Major Subsystem Version
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset MajorSubsysVer
	call WriteString

	;Minor Subsystem Version
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset MinorSubsysVer
	call WriteString

	;Win32 Version Value
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset Win32Version
	call WriteString

	;Size Of Image
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SizeOfImage
	call WriteString

	;Size Of Header
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SizeOfHeaders
	call WriteString

	;CheckSum
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset CheckSum
	call WriteString

	;Subsystem
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset Subsystem
	call WriteString

	;Dll Characteristics
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset DllCharacter
	call WriteString

	;Size Of Stack Reserve
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SizeOfStackRes
	call WriteString

	;Size Of Stack Commit
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SizeOfStackCom
	call WriteString

	;Size Of Heap Reserve
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SizeOfHeapRes
	call WriteString

	;Size Of Heap Commit
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SizeOfHeapCom
	call WriteString

	;Loader Flags
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset LoaderFlags
	call WriteString

	;Number Of RVA And Sizes
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset NumberOfRvaAndS
	call WriteString


;DATA_DIRECTORIES
	push offset DataDirectories
	call WriteString
	
	;Export Directory RVA
	push offset ExportDir
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	mov exportRVA, edi			;save ExportDirectoryRVA
	call WriteHex

	;Export Directory Size 
	push offset Sz
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex

	;Import Directory RVA
	push offset ImportDir
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	mov importRVA, edi			;save ImportDirectoryRVA
	call WriteHex

	;Export Directory Size 
	push offset Sz
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	

;SECTION_HEADERS
	push offset SectionHeader
	call WriteString

	mov eax, sectionLocation
	mov lpFileBuffer, eax
mov ecx, sectionSize 
L1:
	;Name
	push lpFileBuffer
	call WriteString
	push offset endl
	call WriteString

	;Virtual Size
	push offset white_space
	call WriteString
	add lpFileBuffer, 8
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset VirtualSize
	call WriteString

	;Virtual Address
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset VirtualAddress
	call WriteString

	;Size Of Raw Data
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset SizeOfRawData
	call WriteString

	;Pointer To Raw Data
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset PointerToRawData
	call WriteString

	;Pointer To Relocations
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset PointerToRelocation
	call WriteString

	;Pointer To Line Numbers
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset PointerToLinenumbers
	call WriteString

	;Number Of Relocations
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset NumberOfRelocations
	call WriteString

	;Number Of Line Numbers
	push offset white_space
	call WriteString
	add lpFileBuffer, 2
	mov eax, lpFileBuffer
	movzx edi, word ptr [eax]
	call WriteHex
	push offset NumberOfLinenumbers
	call WriteString
	
	;Characteristics
	push offset white_space
	call WriteString
	add lpFileBuffer, 4
	mov eax, lpFileBuffer
	mov edi, dword ptr [eax]
	call WriteHex
	push offset Characteristics_sec
	call WriteString

	add lpFileBuffer, 4

	dec ecx
	jnz L1


;EXPORT_DIRECTORY
	
	mov ecx, exportRVA
	cmp ecx, 0				
	je IMPORT_DIR		;if (IMAGE_DIRECTORY_ENTRY_EXPORT == 0) jmp to IMPORT_DIR

	push offset ExportDirectory
	call WriteString
	
	;get export offset
	push exportRVA
	call RVAtoOffset 
	mov edx, lpBufferAddress
	add edx, eax
	mov eax, dword ptr [edx + 18h]		;eax = NumberOfFunctions
	mov numberOfFunctions, eax
	mov eax, dword ptr [edx + 20h]		;eax = AddressOfNames	
	push eax
	call RVAtoOffset	
	mov edx, lpBufferAddress
	add edx, eax
	
mov ecx, numberOfFunctions
nextExport:
	cmp ecx, 0
	je IMPORT_DIR

	push offset white_space
	call WriteString
	push dword ptr [edx]
	call RVAtoOffset	
	mov ebx, lpBufferAddress
	add ebx, eax
	push ebx
	call WriteString
	push offset endl
	call WriteString

	dec ecx
	add edx, 4
	jmp nextExport



;IMPORT_DIRECTORY
IMPORT_DIR:
	push offset ImportDirectory
	call WriteString

	push importRVA
	call RVAtoOffset 
	add eax, lpBufferAddress
	mov lpFileBuffer, eax

nextImport:
	mov edx, lpFileBuffer
	mov eax, dword ptr [edx]		;OriginalFirstThunk
	xor eax, dword ptr [edx + 16]		;FirstThunk
	test eax, eax
	jz quit				;if OriginalFirstThunk == 0 || FirstThunk == 0 -> quit

	;Modules Name
	push offset endl
	call WriteString
	mov eax, dword ptr [edx + 12]		;Name
	push eax
	call RVAtoOffset	
	add eax, lpBufferAddress
	push eax
	call WriteString
	push offset endl
	call WriteString

	mov edx, lpFileBuffer
	cmp edx, 0
	jz byFirstThunk
	mov eax, dword ptr [edx]
	jmp calcOffset

	byFirstThunk:
		mov eax, dword ptr [edx + 10h]

	calcOffset:
		push eax
		call RVAtoOffset	
		add eax, lpBufferAddress
		mov edx, eax

	;Function Name
listFunc:
	cmp dword ptr [edx], 0
	jne nextFunc
	add lpFileBuffer, 14h		;point to next import
	jmp nextImport
		
nextFunc:
	test dword ptr [edx], 80000000h
	jnz byOrdinal

	;by Name
	mov eax, dword ptr [edx]
	push eax
	call RVAtoOffset	
	add eax, lpBufferAddress
	mov ebx, eax
	;print name
	push offset white_space
	call WriteString
	add ebx, 2
	push ebx
	call WriteString
	push offset endl
	call WriteString
	jmp continueFunc

	byOrdinal:
		push offset white_space
		call WriteString
		push offset Ordinal
		call WriteString
		mov edi, dword ptr [ebx]
		call WriteHex
		push offset endl
		call WriteString

continueFunc:
	add edx, 4
	jmp listFunc



quit:
	call GetProcessHeap
	push lpBufferAddress			;lpMem
	push HEAP_NO_SERIALIZE			;dwFlags = 1
	push eax						;hHeap
	call HeapFree
	push NULL
	call ExitProcess


error:
	push offset errorLog
	call WriteString
	call GetLastError
	push -1
	call ExitProcess
	

main endp



RVAtoOffset proc		;RVAtoOffset (RVA)
	push ebp
	mov ebp, esp
	push ecx
	push edx
	push edi

	mov edx, sectionLocation		;edx = SectionHeaders offset
	mov ecx, sectionSize		;ecx = NumOfSections
section_loop:
	cmp ecx, 0		
	jle done

	mov edi, dword ptr [ebp + 8]		;RVA
	
	cmp edi, dword ptr [edx + 12]		
	jl next_section				;if RVA < VirtualAddress jmp to next

	mov eax, dword ptr [edx + 12]			;eax = VirturalAddress
	add eax, dword ptr [edx + 8]	;eax += VirtualSize
	cmp edi, eax
	jge next_section    ;if RVA >= eax jmp to next

	mov eax, dword ptr [edx + 12]		
	sub edi, eax		;edi = RVA - VirtualAdress
	mov eax, dword ptr [edx + 14h]			;eax = PoiterToRawDaTa
	add eax, edi			;result = eax + edi
	jmp finished

	next_section:
		add edx, 28h	; point to next section
		dec ecx
		jmp section_loop
	
	done:
		mov eax, edi		;return result to eax

finished:
	pop edi
	pop edx
	pop ecx
	pop ebp
	ret 4

RVAtoOffset endp



WriteHex proc		;void itohex (int lpFileBuffer, char* hex)
	;convert integer to hex
	push ebp
	mov ebp, esp
	pushad

	mov eax, edi
	mov esi, offset hex
	mov ebx, 0		;count the number of digits
	mov ecx, 16		;base

L1:
	xor edx, edx		;clear remainder
	div ecx				;eax /= ebx
	cmp dl, 9			
	ja AF				;if above 9 jmp to AF

	jmp Base10			;else jmp to Base10

AF:
	add dl, 37h		;A - F
	push edx		;push remainder onto stack
	inc ebx			;inc counter
	cmp eax, 0		
	jne L1			;if eax != 0 jmp L1

	jmp L2		;else jmp to L2

Base10:
	add dl, 30h		;convert to ascii
	push edx		;push remainder onto stack
	inc ebx			;inc counter
	cmp eax, 0		
	jne L1			;if eax != 0 jmp L1

L2:
	pop edx				;pop remainder off the stack
	mov byte ptr [esi], dl		;store in char* hex
	inc esi				;inc pointer
	dec ebx				;dec counter
	cmp ebx, 0			
	jne L2				;if counter != 0 jmp to L2
	mov byte ptr [esi], 0		;add null terminator to string

	push offset hex
	call WriteString

	popad
	pop ebp
	ret 4

WriteHex endp


GetHandle proc
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov hInput, eax		;hInput = eax

	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov hOutput, eax		;hOutput = eax
	
	ret
GetHandle endp


ReadString proc
	push ebp
	mov ebp, esp
	sub esp, 4
	pushad
	
	push NULL						;pInputControl = NULL
	lea ebx, DWORD PTR [ebp - 4]
	push ebx						;lpNumberOfCharsRead = [ebp - 4]
	push MAXBUF						;nNumberOfCharsToRead = MAXBUF = 100
	push DWORD PTR [ebp + 8] 		;lpBuffer = [ebp + 8]
	push hInput						;hConsoleInput
	call ReadConsole

	;search line feed (0Dh) character and remove it 
	mov edi, dword ptr [ebp + 8]
	mov ecx, MAXBUF 
	cld 						; search forward 
	mov al, 0Dh 
	repne scasb 
	jne L2 						; if not found 0Dh 
	dec edi 
	jmp L3 
L2:
	mov edi, dword ptr [ebp + 8]
	add edi, MAXBUF 
L3:	
	mov byte ptr [edi], 0 		; add null byte 
	
	popad
	add esp, 4
	pop ebp
	ret 4
	
ReadString endp


WriteString proc
	push ebp
	mov ebp, esp
	sub esp, 4			;allocated space for lpNumberOfCharsWritten
	pushad				;push EAX, ECX, EDX, EBX, EBP, ESP, EBP, ESI, EDI onto the stack
	
	push DWORD PTR [ebp + 8]
	call Strlen
	
	push NULL							;lpReserved = NULL
	lea ebx, DWORD PTR [ebp - 4]		
	push ebx							;lpNumberOfCharsWritten = [ebp - 4]
	push eax							;nNumberOfCharsToWrite = eax = Strlen
	push DWORD PTR [ebp + 8]			;*lpBuffer = [ebp + 8]
	push hOutput							;hConsoleOutput
	call WriteConsole
	
	popad
	add esp, 4
	pop ebp
	ret 4
	
WriteString endp


Strlen proc
	push ebp
	mov ebp, esp
	push edi
	
	mov edi, DWORD PTR [ebp + 8]
	mov eax, 0
L1:
	cmp BYTE PTR [edi], NULL		;if [edi] == NULL => break
	je L2
	inc edi
	inc eax
	jmp L1
L2:
	pop edi
	pop ebp
	ret 4
	
Strlen endp

end main