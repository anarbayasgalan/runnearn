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
  gradientStyle = '';

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

  onMouseMove(event: MouseEvent) {
    const x = (event.clientX / window.innerWidth) * 100;
    const y = (event.clientY / window.innerHeight) * 100;

    this.gradientStyle = `
      radial-gradient(
        circle at ${x}% ${y}%,
        rgba(159, 122, 234, 0.15) 0%,
        rgba(99, 102, 241, 0.1) 25%,
        rgba(168, 85, 247, 0.08) 50%,
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
}
