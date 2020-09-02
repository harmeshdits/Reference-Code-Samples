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
      <form @submit.prevent="handleSubmit" class="form-signin">
        <span id="reauth-email" class="reauth-email"></span>
        <div class="form-group">
          <input
            type="email"
            id="email"
            class="form-control"
            :class="{ 'is-invalid': submitted && $v.user.username.$error}"
            placeholder="Email address"
            name="email"
            v-model="user.username"
            autofocus
          />
          <div
            v-if="submitted && !$v.user.username.required"
            class="invalid-feedback"
          >Email is required</div>
          <span v-if="!$v.user.username.email">Email is invalid</span>
        </div>

        <div class="signIn">
          <button class="btn btn-lg btn-primary btn-block btn-signin">Recover Password</button>
        </div>
      </form>
      <hr />
      <!-- /form -->
      <div class="signUp">
        Back to
        <router-link to="/login" class="forgot-password">Login</router-link>
      </div>
    </div>
    <!-- /card-container -->
  </div>
  <!-- /container -->
</template>

<script>
import { required, email } from "vuelidate/lib/validators";
import { mapGetters } from "vuex";
import { FORGOTPASSWORD } from "@/app/store/action-types";

export default {
  name: "auth-forgot-password",
  data() {
    return {
      user: {
        username: ""
      },
      submitted: false
    };
  },

  validations: {
    user: {
      username: { required, email }
    }
  },
  methods: {
    handleSubmit() {
      this.submitted = true;
      // stop here if form is invalid
      this.$v.$touch();
      if (this.$v.$invalid) {
        return;
      }
      this.$store
        .dispatch(FORGOTPASSWORD, this.user)
        .then((success) => {
          this.submitted = false;
          if(success)
          {this.$router.push({ name: "login" });
          this.resetForm();
          }
        });
    }
  },
  computed: {
    ...mapGetters(["authError"])
  }
};
</script>


