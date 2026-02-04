import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  loginForm: FormGroup;
  errorMsg = '';
  isLoading = false;

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router
  ) {
    this.loginForm = this.fb.group({
      userName: ['', [Validators.required]],
      userPass: ['', [Validators.required]]
    });
  }

  onSubmit() {
    if (this.loginForm.valid) {
      this.isLoading = true;
      this.errorMsg = '';
      const { userName, userPass } = this.loginForm.value;

      this.auth.login(userName, userPass).subscribe({
        next: (res) => {
          this.isLoading = false;
          if (res.status === 0) {
            this.router.navigate(['/dashboard']);
          } else {
            this.errorMsg = res.desc || 'Login failed';
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
}
