<template>
  <div class="container">
    <div class="card card-container">
      <!-- <img class="profile-img-card" src="//lh3.googleusercontent.com/-6V8xOA6M7BA/AAAAAAAAAAI/AAAAAAAAAAA/rzlHcD0KYwo/photo.jpg?sz=120" alt="" /> -->
      <img
        id="profile-img"
        class="profile-img-card"
        src="//ssl.gstatic.com/accounts/ui/avatar_2x.png"
      />
      <p id="profile-name" class="profile-name-card"></p>

      <div class="alert alert-danger" v-if="authError">
        {{ authError }}
      </div>

      <form @submit.prevent="handleSubmit" class="form-signin" autocomplete="off">
        <div class="form-group">
          <input
            type="text"
            id="username"
            class="form-control"
            :class="{ 'is-invalid': submitted && $v.user.username.$error}"
            placeholder="Email"
            name="username"
            v-model="user.username"
            autofocus
          />
          <div
            v-if="submitted && !$v.user.username.required"
            class="invalid-feedback"
          >Email is required</div>
          <span v-if="!$v.user.username.email">Email is invalid</span>
        </div>

        <div class="form-group">
          <input
            type="password"
            id="inputPassword"
            class="form-control"
            :class="{ 'is-invalid': submitted && $v.user.password.$error }"
            name="password"
            v-model="user.password"
            placeholder="Password"
          />

          <div
            v-if="submitted && !$v.user.password.required"
            class="invalid-feedback"
          >Password is required</div>
        </div>
        <div id="remember">
          <label class="checkbox">
            <input type="checkbox" />
            <span class="primary"></span>
          </label>
          <span class="checkActive">Remember me</span>
          <!-- <label>
            <input type="checkbox" value="remember-me" /> Remember me
          </label>-->
        </div>
        <div class="signIn">
          <button  class="btn btn-lg btn-primary btn-block btn-signin">Sign in</button>
        </div>
      </form>
      <!-- /form -->
      <div class="forgot-password">
        <router-link to="/forgot-password">Forgot the password?</router-link>
      </div>
      <hr />
      <div class="signUp">
        Don't have an account?
        <router-link to="/register">Sign Up</router-link>
      </div>
    </div>
    <!-- /card-container -->
  </div>
  <!-- /container -->
</template>

<script>
import { mapGetters } from "vuex";
import { required,email} from "vuelidate/lib/validators";
import { LOGIN } from "@/app/store/action-types";

export default {
  name: "auth-login",
  data() {
    return {
      user: {
        username: "",
        password: ""
      },
      submitted: false
    };
  },
  validations: {
    user: {
      username: { required,email },
      password: { required },
      rememberme: false
    }
  },
  methods: {
    handleSubmit() {
      debugger;
      this.submitted = true;
      // stop here if form is invalid
      this.$v.$touch();
      if (this.$v.$invalid) {
        return;
      }
      this.$store
        .dispatch(LOGIN, this.user)
        .then((success) => {
          this.submitted = false;
          if(success) this.$router.push({ name: "home" });
        });

    }
  },
  computed: {
    ...mapGetters(["authError"])
  }
};
</script>


