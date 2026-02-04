import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-setup-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="setup-container">
      <div class="card setup-card">
        <h2 class="text-gradient">Complete Profile</h2>
        <p style="color: var(--color-text-muted); margin-bottom: 2rem;">Add your company details</p>

        <form [formGroup]="setupForm" (ngSubmit)="onSubmit()">
          
          <div class="form-group">
            <label>Profile Picture</label>
            <div class="file-upload-wrapper">
               <input type="file" (change)="onFileSelected($event)" accept="image/*" class="input-field">
            </div>
            <div *ngIf="previewUrl" class="image-preview">
              <img [src]="previewUrl" alt="Preview">
            </div>
          </div>

          <div class="form-group">
            <label>Company Name</label>
            <input type="text" formControlName="companyName" class="input-field" placeholder="Enter your company name">
          </div>

          <div class="form-group">
            <label>Company Details</label>
            <textarea formControlName="details" class="input-field" rows="4" placeholder="Tell us about your company..."></textarea>
          </div>

          <div *ngIf="errorMsg" class="error-msg">
            {{ errorMsg }}
          </div>

          <button type="submit" class="btn btn-primary" [disabled]="isLoading" style="width: 100%; margin-top: 1rem;">
            {{ isLoading ? 'Saving...' : 'Finish Setup' }}
          </button>
          
          <button type="button" class="btn btn-secondary" (click)="skipSetup()" style="width: 100%; margin-top: 0.5rem; background: transparent; border: 1px solid var(--color-border); color: var(--color-text-muted);">
            Skip for now
          </button>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .setup-container {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      position: relative;
      z-index: 2;
    }
    .setup-card {
      width: 100%;
      max-width: 500px;
      padding: 2.5rem;
      background: hsla(0, 0%, 100%, 0.8);
      backdrop-filter: blur(12px);
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 0 0 1px rgba(0,0,0,0.05);
      border-radius: 1rem;
    }
    .image-preview {
      margin-top: 1rem;
      width: 100px;
      height: 100px;
      border-radius: 50%;
      overflow: hidden;
      border: 2px solid hsl(var(--color-primary));
    }
    .image-preview img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    .form-group { margin-bottom: 1.5rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 600; color: hsl(var(--color-text-main)); }
    .input-field { width: 100%; padding: 0.75rem; border-radius: 0.5rem; border: 1px solid #e2e8f0; background: white; color: #1e293b; }
    .error-msg { color: hsl(var(--color-error)); background: hsla(var(--color-error), 0.1); padding: 0.75rem; border-radius: 0.5rem; margin-bottom: 1rem; }
  `]
})
export class SetupProfileComponent implements OnInit {
  setupForm: FormGroup;
  errorMsg = '';
  isLoading = false;
  previewUrl: string | null = null;
  base64Image: string | null = null;

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router
  ) {
    this.setupForm = this.fb.group({
      companyName: ['', [Validators.required]],
      details: ['']
    });
  }

  ngOnInit() {
    const state = window.history.state;
    if (state && state['companyName']) {
      this.setupForm.patchValue({
        companyName: state['companyName']
      });
    }
  }

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = () => {
        this.previewUrl = reader.result as string;
        this.base64Image = this.previewUrl;
      };
      reader.readAsDataURL(file);
    }
  }

  onSubmit() {
    this.isLoading = true;
    this.errorMsg = '';

    const payload = {
      companyName: this.setupForm.get('companyName')?.value,
      details: this.setupForm.get('details')?.value,
      picture: this.base64Image
    };

    this.auth.updateCompany(payload).subscribe({
      next: (res) => {
        this.isLoading = false;
        if (res.responseCode === 0) {
          this.router.navigate(['/dashboard']);
        } else {
          this.errorMsg = res.responseDesc || 'Update failed';
        }
      },
      error: (err) => {
        this.isLoading = false;
        this.errorMsg = 'Connection error';
        console.error(err);
      }
    });
  }

  skipSetup() {
    this.router.navigate(['/dashboard']);
  }
}
