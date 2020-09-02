import axios from 'axios';
import { LocalStorageService } from "../localstorage.service";
import { errorMessages } from "../../config/messages.config";

import { apiBaseUrl } from '@/environment/environment';

/**
 * Axios basic configuration
 * Some general configuration can be added like timeout, headers, params etc. More details can be found on https://github.com/axios/axios
 * */
const config = {
  baseURL: apiBaseUrl
};

/**
 * Creating the instance of Axios
 * It is because, in large scale application we may need to consume APIs from more than single server,
 * So, may need to create multiple http client with different config
 * Only this client will be used rather than axios in the application
 **/
const httpClient = axios.create(config);

// Declare a request interceptor
httpClient.interceptors.request.use(
  request => {
    if (request.method.toUpperCase() == "POST") {
      request.headers["Content-Type"] = "application/json";
    }
    // request.headers.source = source;
    const isLoggedIn = LocalStorageService.isAuthenticated();
    if (isLoggedIn) {
      const token = LocalStorageService.getAuthorizationToken();
      request.headers.Authorization = `Basic ${token}`;
    }

    return request;
  },
  error => {
    return Promise.reject(error);
  }
);

// declare a response interceptor
httpClient.interceptors.response.use(
  response => {
    // do something with the response data
    return Promise.resolve(response.data);
  },
  error => {
    // handle the response error
    const { response } = error;
debugger;
    if (response) {
      const { status, data } = response;

      let error;

      if(data.Message) {
        error = data.Message;
      } else if(data.errors) {
        debugger;
        for(let key in  data.errors) {
          error = data.errors[key][0];
          break;
        }
      } else {
        error = errorMessages.UNKNOWN_ERROR;
      }

      // place your reentry code
      if (status === 401) {
        return Promise.reject(error);
      } else {
        return Promise.reject(error);
      }
    } else {
      if (error.message == "Network Error") {
        return Promise.reject(errorMessages.API_NOT_AVAILABLE);
      } else {
        return Promise.reject(error.Message);
      }
    }
  }
);


export default httpClient;
