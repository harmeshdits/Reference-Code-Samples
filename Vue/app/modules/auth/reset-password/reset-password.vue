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
            type="password"
            id="password"
            class="form-control"
            :class="{ 'is-invalid': submitted && $v.user.password.$error}"
            placeholder="New Password"
            name="password"
            v-model="user.password"
            autofocus
          />
          <div
            v-if="submitted && !$v.user.password.required"
            class="invalid-feedback"
          >Password is required</div>
                <span v-if="!$v.user.password.minLength">Password must have at least 8 letters.</span>

        </div>

        <div class="form-group">
          <input
            type="password"
            id="confirmPassword"
            class="form-control"
            :class="{ 'is-invalid': submitted && $v.user.confirmPassword.$error }"
            name="confirmPassword"
            v-model="user.confirmPassword"
            placeholder="Confirm Password"
          />

          <div
            v-if="submitted && !$v.user.confirmPassword.required"
            class="invalid-feedback"
          >Password is required</div>
          <span v-else-if="!$v.user.confirmPassword.sameAsPassword">Passwords must be identical</span>
        </div>

        <button class="btn btn-lg btn-primary btn-block btn-signin">Reset Password</button>
      </form>
    </div>
    <!-- /card-container -->
  </div>
  <!-- /container -->
</template>

<script>
import { required, sameAs, minLength } from "vuelidate/lib/validators";
import { mapGetters } from "vuex";
import { VALIDATETOKEN,RESETPASSWORD} from "@/app/store/action-types";

export default {
  beforeCreate(){

    var username=this.$route.query.email;
    var token=this.$route.query.token;

    var  user={
       username:username,
       token:token,
     }
     if(!username || !token)
     {
       this.$router.push({ name: "login" })
       return;
     }
      this.$store
        .dispatch(VALIDATETOKEN, user)
        .then((success) => {
          this.submitted = false;
          if(!success)
          {this.$router.push({ name: "error" });
          }
        });
    },

  name: "auth-reset-password",
  data() {
    return {
      user: {
        password: "",
        confirmPassword: ""
      },
      submitted: false
    };
  },

  validations: {
    user: {
      password: { required, minLength: minLength(8) },
      confirmPassword: { required, sameAsPassword: sameAs("password") }
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
var  user={
       username:this.$route.query.email,
       newPassword:this.user.confirmPassword
     }

      this.$store
        .dispatch(RESETPASSWORD,user)
         .then((success) => {
          this.submitted = false;
          if(success)
          {this.$router.push({ name: "login" });
          }
        });
    },
    computed: {
    ...mapGetters(["authError"])
  }
  }
};
</script>

