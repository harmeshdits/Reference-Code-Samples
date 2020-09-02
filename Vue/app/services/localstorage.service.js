

import { TIMEOUT_IN_MINUTES, TIMEOUT_IN_DAYS } from '../config/api.config';

const LOCALSTORAGE_AUTH_USER_KEY = 'AuthUser';
const LOCALSTORAGE_TOKEN_KEY = 'AuthToken';
const LOCALSTORAGE_EXPIRES_AT = "ExpiresAt";
const LOCALSTORAGE_REMEMBER_ME = "RememberMe";

const storeAuthToken = (token) => {
    localStorage.setItem(LOCALSTORAGE_TOKEN_KEY, token);
}

const removeAuthToken = () => {
    localStorage.removeItem(LOCALSTORAGE_TOKEN_KEY);
}

const getAuthorizationToken = () => {
    return localStorage.getItem(LOCALSTORAGE_TOKEN_KEY);
}

const getUserDetail = () => {
    let userDetailData = localStorage.getItem(LOCALSTORAGE_AUTH_USER_KEY);

    if (userDetailData)
        return JSON.parse(userDetailData);

    return null;
}

const isAuthenticated = () => {
    if (localStorage.getItem(LOCALSTORAGE_AUTH_USER_KEY)) {
        // if (localStorage.getItem(LOCALSTORAGE_EXPIRES_AT)) {
        //     if (isPasswordActive()) {
        //         return true;
        //     }
        //     else {
        //         clearLocalStorage();
        //         return false;
        //     }
        // }
        // else {
        return true;
        //}
    }
    return false;
}

const storeAuthUser = (data, remember = false) => {
    debugger;
    storeAuthToken(data.token);
    delete data.Token;
    localStorage.setItem(LOCALSTORAGE_AUTH_USER_KEY, JSON.stringify(data));

    if (remember === true) {
        setExpiresAtInDays();
    } else {
        setExpiresAtInMinutes();
    }
}

const isRememberMeChecked = () => {
    return localStorage.getItem(LOCALSTORAGE_REMEMBER_ME) ? true : false;
}

const setExpiresAtInMinutes = () => {
    var currentDate = new Date();
    currentDate.setMinutes(currentDate.getMinutes() + TIMEOUT_IN_MINUTES);
    var expiryMiliseconds = currentDate.getTime();
    localStorage.setItem(LOCALSTORAGE_EXPIRES_AT, String(expiryMiliseconds));
}

const setExpiresAtInDays = () => {
    var currentDate = new Date();
    currentDate.setDate(currentDate.getDate() + TIMEOUT_IN_DAYS);
    var expiryMiliseconds = currentDate.getTime();
    localStorage.setItem(LOCALSTORAGE_EXPIRES_AT, String(expiryMiliseconds));
    localStorage.setItem(LOCALSTORAGE_REMEMBER_ME, "true");
}

const logout = () => {
    localStorage.clear();
};

export const LocalStorageService = {
    getUserDetail,
    getAuthorizationToken,
    isAuthenticated,
    storeAuthUser,
    storeAuthToken,
    removeAuthToken,
    isRememberMeChecked,
    setExpiresAtInMinutes,
    setExpiresAtInDays,
    logout
}
