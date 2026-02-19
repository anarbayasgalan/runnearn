import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router, RouterModule } from '@angular/router';
import { InteractiveBackgroundComponent } from '../../components/interactive-background/interactive-background.component';
import { SocialAuthService, GoogleLoginProvider, FacebookLoginProvider, SocialUser, GoogleSigninButtonModule } from '@abacritt/angularx-social-login';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule, InteractiveBackgroundComponent, GoogleSigninButtonModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent implements OnInit {
  loginForm: FormGroup;
  errorMsg = '';
  isLoading = false;
  gradientStyle = '';

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router,
    private socialAuthService: SocialAuthService
  ) {
    this.loginForm = this.fb.group({
      userName: ['', [Validators.required]],
      userPass: ['', [Validators.required]]
    });
  }

  ngOnInit() {
    this.socialAuthService.authState.subscribe((user) => {
      this.handleSocialLogin(user.provider, user);
    });


  }

  onMouseMove(event: MouseEvent) {
    const x = (event.clientX / window.innerWidth) * 100;
    const y = (event.clientY / window.innerHeight) * 100;

    this.gradientStyle = `
      radial-gradient(
        circle at ${x}% ${y}%,
        hsla(25, 100%, 50%, 0.15) 0%,
        hsla(210, 72%, 52%, 0.1) 25%,
        hsla(25, 100%, 60%, 0.05) 50%,
        transparent 70%
      )
    `;
  }

  onSubmit() {
    if (this.loginForm.valid) {
      this.isLoading = true;
      this.errorMsg = '';
      const { userName, userPass } = this.loginForm.value;

      this.auth.login(userName, userPass).subscribe({
        next: (res) => {
          this.isLoading = false;
          if (res.responseCode === 0) {
            this.router.navigate(['/dashboard']);
          } else {
            this.errorMsg = res.responseDesc || 'Login failed';
          }
        },
        error: (err) => {
          this.isLoading = false;
          this.errorMsg = 'Connection error';
          console.error(err);
        }
      });
    }
  }

  signInWithFB(): void {

    this.socialAuthService.signIn(FacebookLoginProvider.PROVIDER_ID).then((user: SocialUser) => {
    }).catch(err => {
      this.errorMsg = 'Facebook Login Failed';
      console.error(err);
    });
  }

  handleSocialLogin(provider: string, user: SocialUser) {
    this.isLoading = true;
    this.errorMsg = '';
    this.auth.loginSocial(provider, user.idToken || user.authToken, user.email, user.name, user.photoUrl).subscribe({
      next: (res) => {
        this.isLoading = false;
        if (res.responseCode === 0) {
          this.router.navigate(['/dashboard']);
        } else {
          this.errorMsg = res.responseDesc || 'Login failed';
        }
      },
      error: (err) => {
        this.isLoading = false;
        this.errorMsg = 'Connection error';
        console.error(err);
      }
    });
  }
}

