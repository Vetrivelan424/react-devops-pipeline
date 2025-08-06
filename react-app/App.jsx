import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button.jsx'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card.jsx'
import { Badge } from '@/components/ui/badge.jsx'
import { CheckCircle, GitBranch, Server, Container, Cloud, Zap } from 'lucide-react'
import './App.css'

function App() {
  const [deploymentStatus, setDeploymentStatus] = useState('idle')
  const [buildNumber, setBuildNumber] = useState(42)
  const [lastDeployment, setLastDeployment] = useState(new Date().toLocaleString())

  const handleDeploy = () => {
    setDeploymentStatus('deploying')
    setTimeout(() => {
      setDeploymentStatus('success')
      setBuildNumber(prev => prev + 1)
      setLastDeployment(new Date().toLocaleString())
    }, 3000)
  }

  const pipelineSteps = [
    { name: 'Source Control', icon: GitBranch, status: 'completed', description: 'GitHub repository' },
    { name: 'Build & Test', icon: Zap, status: 'completed', description: 'Jenkins CI/CD' },
    { name: 'Containerize', icon: Container, status: 'completed', description: 'Docker packaging' },
    { name: 'Infrastructure', icon: Cloud, status: 'completed', description: 'Terraform provisioning' },
    { name: 'Deploy', icon: Server, status: deploymentStatus === 'success' ? 'completed' : 'pending', description: 'AWS EC2 deployment' }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
      <div className="max-w-6xl mx-auto">
        <header className="text-center mb-12">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            DevOps Pipeline Demo
          </h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            React Application deployed with Terraform, GitHub, Jenkins, Docker, and AWS EC2
          </p>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <CheckCircle className="h-5 w-5 text-green-500" />
                Deployment Status
              </CardTitle>
              <CardDescription>Current application deployment information</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <span className="font-medium">Build Number:</span>
                  <Badge variant="outline">#{buildNumber}</Badge>
                </div>
                <div className="flex justify-between items-center">
                  <span className="font-medium">Status:</span>
                  <Badge 
                    variant={deploymentStatus === 'success' ? 'default' : deploymentStatus === 'deploying' ? 'secondary' : 'outline'}
                    className={deploymentStatus === 'success' ? 'bg-green-500' : ''}
                  >
                    {deploymentStatus === 'success' ? 'Deployed' : deploymentStatus === 'deploying' ? 'Deploying...' : 'Ready'}
                  </Badge>
                </div>
                <div className="flex justify-between items-center">
                  <span className="font-medium">Last Deployment:</span>
                  <span className="text-sm text-gray-600">{lastDeployment}</span>
                </div>
                <Button 
                  onClick={handleDeploy} 
                  disabled={deploymentStatus === 'deploying'}
                  className="w-full"
                >
                  {deploymentStatus === 'deploying' ? 'Deploying...' : 'Deploy New Version'}
                </Button>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Pipeline Architecture</CardTitle>
              <CardDescription>DevOps tools and technologies used</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {pipelineSteps.map((step, index) => (
                  <div key={index} className="flex items-center gap-3 p-3 rounded-lg bg-gray-50">
                    <step.icon className={`h-5 w-5 ${step.status === 'completed' ? 'text-green-500' : 'text-gray-400'}`} />
                    <div className="flex-1">
                      <div className="font-medium text-sm">{step.name}</div>
                      <div className="text-xs text-gray-600">{step.description}</div>
                    </div>
                    <Badge 
                      variant={step.status === 'completed' ? 'default' : 'secondary'}
                      className={step.status === 'completed' ? 'bg-green-500' : ''}
                    >
                      {step.status === 'completed' ? 'Ready' : 'Pending'}
                    </Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Technology Stack</CardTitle>
            <CardDescription>Complete DevOps implementation overview</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="text-center p-4 rounded-lg bg-blue-50">
                <GitBranch className="h-8 w-8 text-blue-600 mx-auto mb-2" />
                <h3 className="font-semibold text-blue-900">Version Control</h3>
                <p className="text-sm text-blue-700">GitHub for source code management and collaboration</p>
              </div>
              <div className="text-center p-4 rounded-lg bg-green-50">
                <Zap className="h-8 w-8 text-green-600 mx-auto mb-2" />
                <h3 className="font-semibold text-green-900">CI/CD Pipeline</h3>
                <p className="text-sm text-green-700">Jenkins for automated build, test, and deployment</p>
              </div>
              <div className="text-center p-4 rounded-lg bg-purple-50">
                <Container className="h-8 w-8 text-purple-600 mx-auto mb-2" />
                <h3 className="font-semibold text-purple-900">Containerization</h3>
                <p className="text-sm text-purple-700">Docker for consistent application packaging</p>
              </div>
              <div className="text-center p-4 rounded-lg bg-orange-50">
                <Cloud className="h-8 w-8 text-orange-600 mx-auto mb-2" />
                <h3 className="font-semibold text-orange-900">Infrastructure</h3>
                <p className="text-sm text-orange-700">Terraform for infrastructure as code</p>
              </div>
              <div className="text-center p-4 rounded-lg bg-red-50">
                <Server className="h-8 w-8 text-red-600 mx-auto mb-2" />
                <h3 className="font-semibold text-red-900">Cloud Platform</h3>
                <p className="text-sm text-red-700">AWS EC2 for scalable compute resources</p>
              </div>
              <div className="text-center p-4 rounded-lg bg-indigo-50">
                <CheckCircle className="h-8 w-8 text-indigo-600 mx-auto mb-2" />
                <h3 className="font-semibold text-indigo-900">Monitoring</h3>
                <p className="text-sm text-indigo-700">Health checks and deployment verification</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

export default App
