import { useEffect, useRef } from 'react';
import { addAuthPageListener, removeAuthPageListener } from './index';
/**
 * 监听授权页生命周期事件（点击返回、点击切换、点击复选框、点击协议等）。
 * 仅在一键登录授权页展示期间触发；自动在卸载时移除监听。
 */
export const useAuthPageEvent = (handler) => {
    const ref = useRef(handler);
    ref.current = handler;
    useEffect(() => {
        const listener = (response) => ref.current(response);
        addAuthPageListener(listener);
        return () => {
            removeAuthPageListener(listener);
        };
    }, []);
};
