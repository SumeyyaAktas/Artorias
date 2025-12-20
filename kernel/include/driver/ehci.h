#ifndef EHCI_H
#define EHCI_H

#include <stdint.h>
#include <stdbool.h>

#define EHCI_CAPLENGTH 0x00
#define EHCI_HCSPARAMS 0x04
#define EHCI_HCCPARAMS 0x08

#define EHCI_USBCMD 0x00
#define EHCI_USBSTS 0x04
#define EHCI_USBINTR 0x08
#define EHCI_FRINDEX 0x0C
#define EHCI_PERIODICLISTBASE 0x14
#define EHCI_ASYNCLISTADDR 0x18
#define EHCI_CONFIGFLAG 0x40
#define EHCI_PORTSC_BASE 0x44

#define CMD_RS (1 << 0)   
#define CMD_HCRESET (1 << 1)    
#define CMD_ASE (1 << 5)    

#define STS_USBINT (1 << 0)    
#define STS_HCHALTED (1 << 12)   
#define STS_ASS (1 << 15)   

#define PORTSC_CCS (1 << 0)    
#define PORTSC_CSC (1 << 1)   
#define PORTSC_PED (1 << 2)    
#define PORTSC_PEDC (1 << 3)    
#define PORTSC_PR (1 << 8)    
#define PORTSC_PP (1 << 12)   
#define PORTSC_OWNER (1 << 13)   

typedef struct __attribute__((aligned(32))) 
{
    volatile uint32_t next_link;
    volatile uint32_t alt_next_link;
    volatile uint32_t token;
    volatile uint32_t buffer[5];

    uint32_t active;
    uint32_t padding[2];
} EhciTD;

#define TD_TOK_ACTIVE (1 << 7)    
#define TD_TOK_HALTED (1 << 6)    
#define TD_TOK_DATABUFFER (1 << 5)   
#define TD_TOK_BABBLE (1 << 4)    
#define TD_TOK_XACT (1 << 3)   
#define TD_TOK_CERR_SHIFT 10
#define TD_TOK_PID_SHIFT 8
#define TD_TOK_LEN_SHIFT 16

#define USB_PACKET_OUT 0
#define USB_PACKET_IN 1
#define USB_PACKET_SETUP 2

#define PTR_TERMINATE (1 << 0)
#define PTR_QH (1 << 1)

typedef struct __attribute__((aligned(128))) 
{
    volatile uint32_t qh_link;
    volatile uint32_t ep_char;
    volatile uint32_t ep_caps;
    volatile uint32_t current_td;

    volatile uint32_t next_td;
    volatile uint32_t alt_next_td;
    volatile uint32_t token;
    volatile uint32_t buffer[5];

    uint32_t active;
    uint32_t td_head;
    uint32_t padding[13];
} EhciQH;

#define QH_EP_ADDR_MASK 0x0000007F
#define QH_EP_ENDP_SHIFT 8
#define QH_EP_ENDP_MASK (0xF << 8)
#define QH_EP_SPEED_SHIFT 12
#define QH_EP_SPEED_MASK (0x3 << 12)
#define QH_EP_DTC (1 << 14)   
#define QH_EP_H (1 << 15)   
#define QH_EP_MAX_PKT_SHIFT 16
#define QH_EP_MAX_PKT_MASK (0x7FF << 16)
#define QH_EP_NAK_RL_SHIFT 28

#define QH_CAP_MULT_SHIFT 30

#define USB_FULL_SPEED 0
#define USB_LOW_SPEED 1
#define USB_HIGH_SPEED 2

typedef struct 
{
    uint8_t request_type;
    uint8_t request;
    uint16_t value;
    uint16_t index;
    uint16_t length;
} __attribute__((packed)) UsbDeviceRequest;

#define USB_REQ_TYPE_IN 0x80
#define USB_REQ_TYPE_OUT 0x00
#define USB_REQ_TYPE_STANDARD 0x00
#define USB_REQ_TYPE_DEVICE 0x00

#define USB_REQ_GET_DESCRIPTOR 0x06
#define USB_REQ_SET_ADDRESS 0x05
#define USB_REQ_SET_CONFIGURATION 0x09

#define USB_DESC_DEVICE 0x01
#define USB_DESC_CONFIGURATION 0x02
#define USB_DESC_STRING 0x03

typedef struct 
{
    uint8_t length;
    uint8_t descriptor_type;
    uint16_t bcd_usb;
    uint8_t device_class;
    uint8_t device_subclass;
    uint8_t device_protocol;
    uint8_t max_packet_size;
    uint16_t vendor_id;
    uint16_t product_id;
    uint16_t bcd_device;
    uint8_t manufacturer;
    uint8_t product;
    uint8_t serial_number;
    uint8_t num_configurations;
} __attribute__((packed)) UsbDeviceDescriptor;

typedef struct 
{
    uint8_t length;
    uint8_t descriptor_type;
    uint16_t total_length;
    uint8_t num_interfaces;
    uint8_t configuration_value;
    uint8_t configuration;
    uint8_t attributes;
    uint8_t max_power;
} __attribute__((packed)) UsbConfigDescriptor;

typedef struct 
{
    uint8_t length;
    uint8_t descriptor_type;
    uint16_t language_id[1];  
} __attribute__((packed)) UsbStringDescriptor;

#define USB_STRING_MAX_LENGTH 128

#define MAX_QH 8
#define MAX_TD 32

typedef struct 
{
    uint32_t mmio_base;
    uint32_t opreg_base;
    uint8_t num_ports;
    
    EhciQH qh_pool[MAX_QH];
    EhciTD td_pool[MAX_TD];

    EhciQH *async_qh;
} EhciController;

void ehci_init_controller(uint8_t bus, uint8_t slot, uint8_t func);
bool ehci_control_transfer(EhciController *hc, uint8_t device_addr, UsbDeviceRequest *req, void *data);
bool ehci_get_device_descriptor(EhciController *hc, uint8_t device_addr, UsbDeviceDescriptor *desc);
bool ehci_set_address(EhciController *hc, uint8_t new_addr);
bool ehci_set_configuration(EhciController *hc, uint8_t device_addr, uint8_t config);
bool ehci_get_string_descriptor(EhciController *hc, uint8_t device_addr, uint8_t string_index, uint16_t language_id, char *output, uint32_t output_size);
bool ehci_get_languages(EhciController *hc, uint8_t device_addr, uint16_t *language_ids, uint8_t *num_languages);

#endif 