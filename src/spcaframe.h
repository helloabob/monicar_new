#define	VIDEO_PACKSIZE		512

typedef enum 
{
	KEY_LEFT_UP,
	KEY_LEFT_DOWN,
	KEY_RIGHT_UP,
	KEY_RIGHT_DOWN,
	KEY_SENSOR,
	KEY_LED,
	KEY_IR_LED,
	KEY_AUDIO,
	KER_REC,
	MAX_KEY,
}PHONE_CMD;

////////////////////////////
enum PHONE_T_CAR_CMD
{
	CAR_FONT=0x01,
	CAR_BACK,
	CAR_R_FONT,
	CAR_L_FONT,
	CAR_R_BACK,
	CAR_L_BACK=0X06,
	CAR_L_ROUND,
	CAR_R_ROUND,
	CAR_STOP,
	CAR_IR_IN=0x0A,
	CAR_IR_OFF,
	CAR_REC_START,
	CAR_REC_END=0x0D,
	CLIENT_RET=0X7D,
	ACK_PACK=0x7F,
};
enum CAR_T_PHONE_CMD
{
	VIODE_PACK=0x01,
	AUDIO_PACK,
};

#define MAX_REC_NUM	2048

#pragma pack(1)
struct Tphead
{
	unsigned char signature;
	unsigned int serial;
	unsigned char cmd;
	unsigned short bodylen;
	unsigned char checknum;
};
struct TCMD
{
	unsigned char 	signature;
	unsigned int 	serial;
	unsigned char 	bodylen;
	unsigned char 	cmd[MAX_KEY];	
	unsigned char 	checknum;
};

struct TREC_CMD
{
	unsigned int 	time;
	unsigned char 	cmd[KEY_RIGHT_DOWN+1];
	
};


struct TVDATA
{
	//struct Tphead m_head;
	unsigned short m_frag_totle;
	unsigned short m_frag_cur;
	unsigned short m_width;
	unsigned short height;
	char DataNuf[VIDEO_PACKSIZE+8];
};
#pragma pack()