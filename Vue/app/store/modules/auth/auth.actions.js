import { AuthService } from '../../../services/auth.service';
import { LOGIN, LOGOUT,REGISTER, RESETPASSWORD,CHANGEPASSWORD,FORGOTPASSWORD,VERIFYEMAIL,VALIDATETOKEN} from '../../action-types';
import { SET_AUTH, PURGE_AUTH, SET_AUTH_ERROR } from '../../mutation-types';
// import { LocalStorageService } from '../../../services/localstorage.service';
export default {
    [LOGIN](context, credentials) {
        return new Promise(resolve => {
            AuthService.login(credentials)
                .then((user) => {
                    context.commit(SET_AUTH, user);
                    resolve(true);
                })
                .catch((response) => {
                    context.commit(SET_AUTH_ERROR, response);
                    resolve(false);
                });
        });
    },
    [LOGOUT](context) {
        context.commit(PURGE_AUTH);
    },
    [REGISTER](context, userRequest) {
        return new Promise((resolve) => {
            AuthService.register(userRequest)
                .then(( user ) => {
                    context.commit(SET_AUTH, user);
                    resolve(true);
                })
                .catch(( response ) => {
                    debugger
                    context.commit(SET_AUTH_ERROR, response);
                    resolve(false);
                });
        });
    },
    [FORGOTPASSWORD](context, userRequest) {
        return new Promise((resolve) => {
            debugger;
            AuthService.forgotPassword(userRequest)
                .then(( user ) => {
                    context.commit(SET_AUTH, user);
                    resolve(true);
                })
                .catch(( response ) => {
                    context.commit(SET_AUTH_ERROR, response);
                    resolve(false);
                });
        });
    },
    [RESETPASSWORD](context, modifyPasswordRequest) {
        return new Promise((resolve) => {
            AuthService.resetPassword(modifyPasswordRequest)
                .then(({ user }) => {
                    context.commit(SET_AUTH, user);
                    resolve(true);
                })
                .catch(( response ) => {
                    context.commit(SET_AUTH_ERROR, response);
                    resolve(false);
                });
        });
    },
    [CHANGEPASSWORD](context, modifyPasswordRequest) {
        return new Promise((resolve) => {
            AuthService.changePassword(modifyPasswordRequest)
                .then(({ user }) => {
                    context.commit(SET_AUTH, user);
                    resolve(true);
                })
                .catch(( response ) => {
                    context.commit(SET_AUTH_ERROR, response);
                    resolve(false);
                });
        });
    },
    [VERIFYEMAIL](context, userRequest) {
        return new Promise((resolve) => {
            AuthService.verifyEmail(userRequest)
                .then(( user ) => {
                    context.commit(SET_AUTH, user);
                    resolve(true);
                })
                .catch(( response ) => {
                    context.commit(SET_AUTH_ERROR, response);
                    resolve(false);
                });
        });
    },
    [VALIDATETOKEN](context, userRequest) {
        return new Promise((resolve) => {
            debugger;
            AuthService.validateToken(userRequest)
                .then(( user ) => {
                    context.commit(SET_AUTH, user);
                    resolve(true);
                })
                .catch(( response ) => {
                    context.commit(SET_AUTH_ERROR, response);
                    resolve(false);
                });
        });
    },
}