//
// @create resources
// windres.exe -J rc -O coff ss_ui_type.rc -o ss_ui_type.o
// or
// rc.exe /r ss_ui_type.rc
//
// @compile
// cc -o keyboardtypo keyboardtypo.c ss_ui_type.o -lwinmm -mwindows -O3
//

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <windows.h>
#include <mmsystem.h>
#include <process.h>
#include <stdbool.h>
#include <shellapi.h>
//
#define WM_USER_SHELLICON (WM_USER + 1)
#define IDR_WAVE1 101
//
bool isButtonPressed = false;
bool exitButton_0 = false;
//
HHOOK keyboardHook;
HINSTANCE hInstance;
NOTIFYICONDATA nid;
HWND hwnd;
LPVOID pData;

// check if a key is a special key

int isSpecialKey(int keyCode)
{
    switch (keyCode) {
    case VK_SHIFT:
    case VK_CONTROL:
    case VK_MENU:
    case VK_LWIN:
    case VK_RWIN:
    case VK_APPS:
    case VK_CAPITAL:
    case VK_NUMLOCK:
    case VK_SCROLL:
    case VK_LSHIFT:
    case VK_RSHIFT:
    case VK_LCONTROL:
    case VK_RCONTROL:
    case VK_LMENU:
    case VK_RMENU:
        return 1;
    default:
        return 0;
    }
}

void PlaySoundFile(LPVOID pSoundData)
{
    if (isButtonPressed) {
        PlaySound((LPCSTR) pSoundData, NULL,
                  SND_MEMORY | SND_NODEFAULT | SND_ASYNC);
        isButtonPressed = false;
    }
}

LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam)
{
    if (nCode == HC_ACTION && (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN)) {
        KBDLLHOOKSTRUCT *pKeyboardHookStruct = (KBDLLHOOKSTRUCT *) lParam;
        if (!(pKeyboardHookStruct->flags & LLKHF_INJECTED)
            && !isSpecialKey(pKeyboardHookStruct->vkCode)) {
            isButtonPressed = true;
            _beginthread(PlaySoundFile, 0, pData);
        }
    }
    return CallNextHookEx(NULL, nCode, wParam, lParam);
}

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    switch (uMsg) {
    case WM_USER_SHELLICON:{
            switch (LOWORD(lParam)) {
            case WM_RBUTTONUP:{
                    POINT lpClickPoint;
                    GetCursorPos(&lpClickPoint);
                    HMENU hPopMenu = CreatePopupMenu();
                    if (hPopMenu) {
                        InsertMenu(hPopMenu, -1, MF_BYPOSITION | MF_STRING, 1,
                                   TEXT("Exit"));
                        InsertMenu(hPopMenu, -1, MF_BYPOSITION | MF_STRING, 2,
                                   TEXT("About"));
                        SetForegroundWindow(hwnd);
                        int selection = TrackPopupMenuEx(hPopMenu,
                                                         TPM_LEFTALIGN |
                                                         TPM_RETURNCMD,
                                                         lpClickPoint.x,
                                                         lpClickPoint.y,
                                                         hwnd, NULL);
                        SendMessage(hwnd, WM_COMMAND, selection, 0);
                        DestroyMenu(hPopMenu);
                    }
                }
                break;
            }
        }
        break;

    case WM_COMMAND:{
            switch (LOWORD(wParam)) {
            case 1:            // Exit menu item
                DestroyWindow(hwnd);
                exitButton_0 = true;

            case 2:            // About menu item
                MessageBox(hwnd, TEXT("\t\n\n\nThis prog produce typewriter sounds upon keystroke.\n\n\n (c) Baka"),
                           TEXT(__FILE__), MB_OK);
                break;
            }
        }
        break;

    case WM_DESTROY:
        Shell_NotifyIcon(NIM_DELETE, &nid);
        PostQuitMessage(0);
        break;

    default:
        return DefWindowProc(hwnd, uMsg, wParam, lParam);
    }
    return 0;
}

void RegisterKeyboardHook()
{
    keyboardHook = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, hInstance, 0);
}

void UnregisterKeyboardHook()
{
    UnhookWindowsHookEx(keyboardHook);
}

void AddTrayIcon(HWND hwnd)
{
    nid.cbSize = sizeof(NOTIFYICONDATA);
    nid.hWnd = hwnd;
    nid.uID = 1;
    nid.uFlags = NIF_ICON | NIF_TIP | NIF_MESSAGE;
    nid.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(102));
    nid.uCallbackMessage = WM_USER_SHELLICON;
    lstrcpyn(nid.szTip, TEXT(__FILE__), sizeof(nid.szTip) / sizeof(TCHAR));
    Shell_NotifyIcon(NIM_ADD, &nid);
}

void RemoveTrayIcon()
{
    Shell_NotifyIcon(NIM_DELETE, &nid);
}

int main()
{
    hInstance = GetModuleHandle(NULL);

    HRSRC hRes = FindResource(hInstance, MAKEINTRESOURCE(IDR_WAVE1), RT_RCDATA);
    HGLOBAL hData = LoadResource(hInstance, hRes);
    pData = LockResource(hData);

    // Create the window class
    LPCTSTR className = TEXT("TrayIconWindowClass");
    WNDCLASS wc = { 0 };
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = className;
    RegisterClass(&wc);

    // Create the window
    HWND hwnd = CreateWindow(className, NULL, 0, CW_USEDEFAULT, CW_USEDEFAULT,
                             CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL,
                             hInstance, NULL);
    AddTrayIcon(hwnd);

    RegisterKeyboardHook();

    MSG msg;
    while (!exitButton_0 && GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    RemoveTrayIcon();
    UnregisterKeyboardHook();
    UnlockResource(pData);
    FreeResource(hData);

    return 0;
}
