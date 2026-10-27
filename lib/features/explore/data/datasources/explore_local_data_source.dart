import '../../domain/entities/compare_startup_item.dart';
import '../../domain/entities/explore_campaign.dart';
import '../../domain/entities/explore_content_item.dart';
import '../../domain/entities/explore_event.dart';
import '../../domain/entities/explore_founder.dart';
import '../../domain/entities/explore_investor.dart';
import '../../domain/entities/explore_startup.dart';
import '../models/explore_campaign_model.dart';
import '../models/explore_content_item_model.dart';
import '../models/explore_event_model.dart';
import '../models/explore_founder_model.dart';
import '../models/explore_investor_model.dart';
import '../models/explore_startup_model.dart';

abstract class ExploreLocalDataSource {
  Future<List<ExploreStartup>> getStartups();
  Future<List<ExploreInvestor>> getInvestors();
  Future<List<ExploreFounder>> getFounders();
  Future<List<ExploreEvent>> getEvents();
  Future<List<ExploreCampaign>> getCampaigns();
  Future<List<CompareStartupItem>> getCompareStartups();
  Future<List<ExploreContentItem>> getSavedContentItems();
  Future<bool> toggleBookmark(String type, int id);
  Future<bool> expressInterest(String type, int id);
  Future<bool> toggleEventRegistration(int eventId);
  Future<bool> toggleFollow(String type, int id);
}

class ExploreLocalDataSourceImpl implements ExploreLocalDataSource {
  ExploreLocalDataSourceImpl() {
    _initMockData();
  }

  final List<ExploreStartup> _startups = [];
  final List<ExploreInvestor> _investors = [];
  final List<ExploreFounder> _founders = [];
  final List<ExploreEvent> _events = [];
  final List<ExploreCampaign> _campaigns = [];
  final List<CompareStartupItem> _compareStartups = [];
  final List<ExploreContentItem> _savedContentItems = [];
  final Set<String> _savedKeys = {};

  void _initMockData() {
    _startups.addAll([
      const ExploreStartupModel(
        id: 1,
        name: 'NovaMed AI',
        initials: 'NM',
        colorHex: 0xFF5548E8,
        tagline: 'AI-powered diagnostics for underserved clinics across MENA.',
        about:
            'NovaMed AI is building next-generation diagnostic tools powered by computer vision and clinical AI. Our platform helps clinics in emerging markets deliver accurate diagnoses without expensive specialists on-site.',
        problem:
            'Over 600M people in MENA and Africa lack access to specialist diagnostic care. Misdiagnosis rates in underserved clinics exceed 35%, leading to preventable deaths.',
        solution:
            'A portable AI diagnostic suite that plugs into existing clinic workflows  —  no specialist required. Trained on 14M clinical images from MENA-specific populations.',
        businessModel:
            'SaaS subscription per clinic (\$200/mo) + pay-per-analysis revenue share. Enterprise contracts with hospital networks.',
        targetMarket:
            '\$48B diagnostics market, \$4.2B addressable in MENA. Targeting 12,000+ clinics in UAE, KSA, Egypt and Jordan.',
        industry: 'HealthTech',
        location: 'Dubai, UAE',
        stage: 'Seed',
        targetAmount: 2400000,
        raisedAmount: 2400000,
        valuation: 18000000,
        equityPct: 13.3,
        minInvestment: 25000,
        deadline: 'Dec 31, 2026',
        isVerified: true,
        isFunded: true,
        investorCount: 12,
        website: 'novamed.ai',
        mrr: 48000,
        monthlyGrowth: 22,
        employees: 18,
        matchScore: 94,
        coverImageUrl:
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=600&h=200&fit=crop&auto=format',
        isSaved: false,
      ),
      const ExploreStartupModel(
        id: 2,
        name: 'GreenStack',
        initials: 'GS',
        colorHex: 0xFF00C48C,
        tagline:
            'Sustainability SaaS for mid-size enterprises to track and reduce carbon.',
        about:
            'GreenStack makes it easy for companies to measure, report, and reduce their carbon footprint  —  from supply chain to operations. Built for the EU CSRD mandate.',
        problem:
            'New EU regulations require 50,000+ companies to report ESG metrics by 2026. Most lack the tools and expertise to comply.',
        solution:
            'A no-code sustainability platform that integrates with existing ERP systems to automate carbon accounting, generate compliance reports, and surface reduction opportunities.',
        businessModel:
            'SaaS tiers starting at . Enterprise contracts with 3-year lock-ins. Integration marketplace for consultants.',
        targetMarket:
            '\$12B ESG software market growing at 28% CAGR. 50,000 newly regulated EU companies.',
        industry: 'CleanTech',
        location: 'Cairo, Egypt',
        stage: 'Series A',
        targetAmount: 8000000,
        raisedAmount: 5200000,
        valuation: 42000000,
        equityPct: 12.0,
        minInvestment: 100000,
        deadline: 'Jan 15, 2027',
        isVerified: true,
        isFunded: false,
        investorCount: 24,
        website: 'greenstack.io',
        mrr: 180000,
        monthlyGrowth: 15,
        employees: 34,
        matchScore: 87,
        coverImageUrl:
            'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=600&h=200&fit=crop&auto=format',
        isSaved: true,
      ),
      const ExploreStartupModel(
        id: 3,
        name: 'FlowSync',
        initials: 'FS',
        colorHex: 0xFFE8A020,
        tagline: 'B2B workflow automation platform for ops-heavy SMEs.',
        about:
            'FlowSync replaces spreadsheet-driven operations with intelligent workflow automation  —  from HR to procurement to customer onboarding.',
        problem:
            'SMEs in emerging markets lose 30% of productivity to manual, disconnected operations. Existing enterprise tools are too expensive and complex.',
        solution:
            'A drag-and-drop workflow builder that connects to WhatsApp, Excel, and popular Arab-market apps. No code required. Deploys in 48 hours.',
        businessModel:
            'Tiered monthly subscription per team (\$49 - \$299/mo). Usage-based charges for automated API executions.',
        targetMarket:
            '2.4M registered SMEs in Saudi Arabia and UAE. \$1.1B addressable automation market.',
        industry: 'SaaS',
        location: 'Riyadh, KSA',
        stage: 'Pre-seed',
        targetAmount: 800000,
        raisedAmount: 600000,
        valuation: 4500000,
        equityPct: 15.0,
        minInvestment: 10000,
        deadline: 'Nov 30, 2026',
        isVerified: false,
        isFunded: false,
        investorCount: 6,
        website: 'flowsync.io',
        mrr: 52000,
        monthlyGrowth: 31,
        employees: 9,
        matchScore: 81,
        coverImageUrl:
            'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=600&h=200&fit=crop&auto=format',
        isSaved: false,
      ),
      const ExploreStartupModel(
        id: 4,
        name: 'EduPath',
        initials: 'EP',
        colorHex: 0xFF3B82F6,
        tagline: 'Adaptive STEM learning platform for K-12 students in Arabic.',
        about:
            'EduPath delivers personalized STEM curricula adapted for Arabic-language curricula with gamification, live tutoring, and AI assessment.',
        problem:
            'Arabic educational content is outdated and fragmented. Rote learning dominates science and math curricula across the region.',
        solution:
            'Gamified bite-sized video lessons aligned with local ministry curriculums, with generative AI solving student questions 24/7.',
        businessModel:
            'B2C subscriptions for parents (\$15/mo) + B2B school licensing contracts across private school networks.',
        targetMarket:
            '85M school-aged children in MENA. Education spending is \$95B annually in the Arab world.',
        industry: 'EdTech',
        location: 'Cairo, Egypt',
        stage: 'Seed',
        targetAmount: 1500000,
        raisedAmount: 1100000,
        valuation: 15000000,
        equityPct: 14.0,
        minInvestment: 50000,
        deadline: 'Feb 28, 2027',
        isVerified: true,
        isFunded: false,
        investorCount: 9,
        website: 'edupath.eg',
        mrr: 28000,
        monthlyGrowth: 19,
        employees: 22,
        matchScore: 78,
        coverImageUrl:
            'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=600&h=200&fit=crop&auto=format',
        isSaved: false,
      ),
      const ExploreStartupModel(
        id: 5,
        name: 'Payra',
        initials: 'PY',
        colorHex: 0xFF8B5CF6,
        tagline: 'Cross-border payment infrastructure built for African & MENA SMEs.',
        about:
            'Payra is the financial infrastructure layer for regional trade  —  enabling businesses to send, receive, and convert money across 22 currencies with same-day settlement.',
        problem:
            'Regional cross-border transactions take 3 days and cost 8 in fees, crippling SME working capital and regional trade.',
        solution:
            'A B2B payments API + wallet platform with real-time FX, regulatory compliance built-in, and local payment rails integration.',
        businessModel:
            'Transaction fee (0.8%) + FX spread (0.5%) + enterprise API licensing. Processing \$2M/day currently.',
        targetMarket:
            '\$48B payment market, growing 20% annually. \$680B intra-regional trade opportunity.',
        industry: 'FinTech',
        location: 'Dubai, UAE',
        stage: 'Series A',
        targetAmount: 12000000,
        raisedAmount: 12000000,
        valuation: 85000000,
        equityPct: 10.0,
        minInvestment: 500000,
        deadline: 'Closed',
        isVerified: true,
        isFunded: true,
        investorCount: 31,
        website: 'payra.com',
        mrr: 320000,
        monthlyGrowth: 28,
        employees: 67,
        matchScore: 76,
        coverImageUrl:
            'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600&h=200&fit=crop&auto=format',
        isSaved: false,
      ),
    ]);

    _investors.addAll([
      const ExploreInvestorModel(
        id: 1,
        name: 'Omar Khalil',
        type: 'Principal',
        firm: 'Wamda Capital',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&auto=format',
        bio:
            'Principal at Wamda Capital with 10+ years investing across MENA tech. Former founder (exited 2018). Focus on early-stage B2B, FinTech, and HealthTech startups with strong unit economics.',
        thesis:
            'I back founders who deeply understand their market and build with capital efficiency. Prefer early-stage where I can add value through network, not just capital.',
        industries: ['FinTech', 'HealthTech', 'SaaS', 'AI / ML'],
        stages: ['Pre-Seed', 'Seed', 'Series A'],
        ticket: '\$200K',
        minTicket: 200000,
        maxTicket: 2000000,
        location: 'Dubai, UAE',
        matchScore: 92,
        isVerified: true,
        portfolio: ['NovaMed AI', 'Payra', 'TechBridge', 'CargoLinx'],
        totalInvested: '\$28M',
        activeDeals: 4,
        followers: 3400,
        matchReasons: [
          'Same industry focus',
          'Preferred funding stage',
          'Matching investment range',
          'Geographic overlap (MENA)',
        ],
        isSaved: true,
        isInterestSent: false,
      ),
      const ExploreInvestorModel(
        id: 2,
        name: 'Ingrid Larsen',
        type: 'Partner',
        firm: 'Nordic Ventures',
        avatarUrl:
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=80&h=80&fit=crop&auto=format',
        bio:
            'Partner at Nordic Ventures, leading investments in ClimateTech, AI, and SaaS. 15+ years venture experience across Europe and cross-border expansion.',
        thesis:
            'Climate and sustainable enterprise infrastructure will be the largest value creation opportunity of the next two decades.',
        industries: ['CleanTech', 'AI / ML', 'SaaS'],
        stages: ['Seed', 'Series A', 'Series B'],
        ticket: '\$1M',
        minTicket: 1000000,
        maxTicket: 5000000,
        location: 'Remote',
        matchScore: 85,
        isVerified: true,
        portfolio: ['GreenStack', 'EcoTrack', 'SustainAI'],
        totalInvested: '\$85M',
        activeDeals: 5,
        followers: 5100,
        matchReasons: [
          'Climate/CleanTech leader',
          'Series A expertise',
          'Cross-border scale network',
        ],
        isSaved: false,
        isInterestSent: false,
      ),
      const ExploreInvestorModel(
        id: 3,
        name: 'Tariq Hassan',
        type: 'Angel Investor',
        firm: 'Independent Angel',
        avatarUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&auto=format',
        bio:
            'Ex-founder (acquired by Careem/Uber). Angel investor in 18 MENA startups. I write \$25K checks and help founders with go-to-market, pricing, and scaling.',
        thesis:
            'First check into exceptional operators. I invest in people first, market second. High conviction, low friction, zero bureaucracy.',
        industries: ['SaaS', 'EdTech', 'E-commerce', 'FinTech'],
        stages: ['Pre-seed', 'Seed'],
        ticket: '\$25K',
        minTicket: 25000,
        maxTicket: 150000,
        location: 'Riyadh, KSA',
        matchScore: 79,
        isVerified: false,
        portfolio: ['FlowSync', 'EduPath', 'ShopLocal'],
        totalInvested: '\$3.2M',
        activeDeals: 6,
        followers: 1800,
        matchReasons: [
          'Pre-Seed specialist',
          'MENA expertise',
          'Operator background',
        ],
        isSaved: false,
        isInterestSent: true,
      ),
      const ExploreInvestorModel(
        id: 4,
        name: 'Amani Osei',
        type: 'VC Partner',
        firm: 'Pan-Region Fund',
        avatarUrl:
            'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=80&h=80&fit=crop&auto=format',
        bio:
            'Partner at Pan-Region Fund. Leading investments in fintech, health, and logistics. Former Goldman Sachs.',
        thesis:
            'Emerging markets are the last great frontier for tech venture. We invest in founders building for regional-first problems with global potential.',
        industries: ['FinTech', 'HealthTech', 'E-commerce'],
        stages: ['Seed', 'Series A', 'Series B'],
        ticket: '\$500K',
        minTicket: 500000,
        maxTicket: 8000000,
        location: 'Cairo, Egypt',
        matchScore: 74,
        isVerified: true,
        portfolio: ['Payra', 'AgriSense', 'HealthPoint'],
        totalInvested: '\$62M',
        activeDeals: 3,
        followers: 7200,
        matchReasons: [
          'Emerging market focus',
          'FinTech specialist',
          'Large ticket size',
        ],
        isSaved: false,
        isInterestSent: false,
      ),
    ]);

    _founders.addAll([
      const ExploreFounderModel(
        id: 1,
        name: 'Sarah Al-Mansouri',
        role: 'Founder & CEO',
        startupName: 'NovaMed AI',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80&h=80&fit=crop&auto=format',
        location: 'Dubai, UAE',
        skills: ['AI/ML', 'HealthTech', 'Fundraising', 'GTM'],
        followers: 1200,
        isVerified: true,
        bio:
            'Building AI diagnostics for MENA clinics. Stanford Medicine Research Fellow. \$2.4M Seed raised.',
        lookingFor: 'Co-investors for Series A expansion',
        isSaved: true,
        isInterestSent: false,
      ),
      const ExploreFounderModel(
        id: 2,
        name: 'Lena Bergstrm',
        role: 'Co-founder & CEO',
        startupName: 'GreenStack',
        avatarUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop&auto=format',
        location: 'Cairo, Egypt',
        skills: ['ESG', 'SaaS', 'Enterprise Sales', 'EU Regulation'],
        followers: 2100,
        isVerified: true,
        bio:
            'Former McKinsey consultant. Building the ESG compliance layer for enterprises.  ARR.',
        lookingFor: 'Series A investors with enterprise network',
        isSaved: false,
        isInterestSent: false,
      ),
      const ExploreFounderModel(
        id: 3,
        name: 'Khalid Al-Otaibi',
        role: 'CEO & Founder',
        startupName: 'FlowSync',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop&auto=format',
        location: 'Riyadh, KSA',
        skills: ['Product', 'B2B Sales', 'Arabic Market', 'Operations'],
        followers: 540,
        isVerified: false,
        bio:
            'Prev ops lead at Saudi Telecom. Building workflow automation for MENA SMEs.',
        lookingFor: 'Pre-Seed investors with KSA enterprise network',
        isSaved: false,
        isInterestSent: false,
      ),
      const ExploreFounderModel(
        id: 4,
        name: 'Yasmin Farouk',
        role: 'Founder & CEO',
        startupName: 'EduPath',
        avatarUrl:
            'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=80&h=80&fit=crop&auto=format',
        location: 'Cairo, Egypt',
        skills: ['EdTech', 'Product', 'Arabic UX', 'Government Relations'],
        followers: 890,
        isVerified: true,
        bio:
            'Former Ministry of Education advisor. 50K students using EduPath. Seed round open.',
        lookingFor: 'Impact investors with EdTech background',
        isSaved: false,
        isInterestSent: false,
      ),
    ]);

    _events.addAll([
      const ExploreEventModel(
        id: 1,
        title: 'MENA Pitch Night 2026',
        type: 'Pitch Night',
        date: 'Oct 14, 2026',
        time: '7:00 PM GST',
        location: 'DIFC Innovation Hub, Dubai',
        isOnline: false,
        price: 150,
        attendeesCount: 342,
        imageUrl:
            'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&h=300&fit=crop&auto=format',
        organizer: 'Wamda Capital',
        description:
            'Ten handpicked startups pitch live to 40+ investors. Seed to Series A stage. Apply to pitch or attend as an investor or observer.',
        isRegistered: false,
        isSaved: false,
      ),
      const ExploreEventModel(
        id: 2,
        title: 'AI Founders Demo Day',
        type: 'Demo Day',
        date: 'Oct 22, 2026',
        time: '2:00 PM CET',
        location: 'Online Webinar',
        isOnline: true,
        onlineLink: 'https://zoom.us/j/96872341001',
        price: null,
        attendeesCount: 1240,
        imageUrl:
            'https://images.unsplash.com/photo-1591115765373-5207764f72e7?w=600&h=300&fit=crop&auto=format',
        organizer: 'AI Founders Community',
        description:
            'Quarterly demo day showcasing the best AI startups from MENA and Europe. 20+ companies presenting. Open to accredited investors.',
        isRegistered: true,
        isSaved: true,
      ),
      const ExploreEventModel(
        id: 3,
        title: 'Fundraising Masterclass & Term Sheet Prep',
        type: 'Workshop',
        date: 'Nov 2, 2026',
        time: '10:00 AM AST',
        location: 'King Abdulaziz Center, Riyadh',
        isOnline: false,
        price: 299,
        attendeesCount: 86,
        imageUrl:
            'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=600&h=300&fit=crop&auto=format',
        organizer: 'Fikraty Accelerator',
        description:
            'Full-day intensive workshop on fundraising for MENA founders. From deck design to term sheet negotiation. Limited to 100 seats.',
        isRegistered: false,
        isSaved: false,
      ),
    ]);

    _campaigns.addAll([
      const ExploreCampaignModel(
        id: 1,
        startupId: 1,
        startupName: 'NovaMed AI',
        initials: 'NM',
        colorHex: 0xFF5548E8,
        coverImageUrl:
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=600&h=200&fit=crop&auto=format',
        industry: 'HealthTech',
        location: 'Dubai, UAE',
        matchScore: 94,
        investmentType: 'Seed equity round',
        stage: 'Seed',
        deadline: 'Dec 31, 2026',
        description:
            'AI-powered diagnostics for underserved clinics across MENA. Closing final tranche of oversubscribed Seed round.',
        targetAmount: 2400000,
        raisedAmount: 2400000,
        minTicket: 25000,
        isInterested: true,
        isSaved: false,
      ),
      const ExploreCampaignModel(
        id: 2,
        startupId: 2,
        startupName: 'GreenStack',
        initials: 'GS',
        colorHex: 0xFF00C48C,
        coverImageUrl:
            'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=600&h=200&fit=crop&auto=format',
        industry: 'CleanTech',
        location: 'Cairo, Egypt',
        matchScore: 87,
        investmentType: 'Series A equity round',
        stage: 'Series A',
        deadline: 'Jan 15, 2027',
        description:
            'Sustainability SaaS for mid-size enterprises to track and reduce carbon. Raising to fund international enterprise sales team.',
        targetAmount: 8000000,
        raisedAmount: 5200000,
        minTicket: 100000,
        isInterested: false,
        isSaved: false,
      ),
      const ExploreCampaignModel(
        id: 3,
        startupId: 3,
        startupName: 'FlowSync',
        initials: 'FS',
        colorHex: 0xFFE8A020,
        coverImageUrl:
            'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=600&h=200&fit=crop&auto=format',
        industry: 'SaaS',
        location: 'Riyadh, KSA',
        matchScore: 81,
        investmentType: 'Pre-Seed SAFE note',
        stage: 'Pre-seed',
        deadline: 'Nov 30, 2026',
        description:
            'B2B workflow automation platform for ops-heavy SMEs. Raising to expand Arabic LLM integrations.',
        targetAmount: 800000,
        raisedAmount: 600000,
        minTicket: 10000,
        isInterested: false,
        isSaved: false,
      ),
    ]);

    _compareStartups.addAll([
      const CompareStartupItem(
        id: 1,
        name: 'NovaMed AI',
        initials: 'NM',
        colorHex: 0xFF5548E8,
        score: 91,
        industry: 'HealthTech',
        stage: 'Seed',
        raised: '\$2.4M',
        mrr: '\$180K',
        monthlyGrowth: '18%',
        runway: '14 months',
      ),
      const CompareStartupItem(
        id: 2,
        name: 'GreenStack',
        initials: 'GS',
        colorHex: 0xFF00A979,
        score: 86,
        industry: 'CleanTech',
        stage: 'Series A',
        raised: '\$4.1M',
        mrr: '\$310K',
        monthlyGrowth: '12%',
        runway: '19 months',
      ),
      const CompareStartupItem(
        id: 3,
        name: 'Payra',
        initials: 'PY',
        colorHex: 0xFF8B5CF6,
        score: 83,
        industry: 'FinTech',
        stage: 'Seed',
        raised: '\$1.8M',
        mrr: '\$140K',
        monthlyGrowth: '22%',
        runway: '11 months',
      ),
      const CompareStartupItem(
        id: 4,
        name: 'FlowSync',
        initials: 'FS',
        colorHex: 0xFF0EA5E9,
        score: 78,
        industry: 'SaaS',
        stage: 'Pre-seed',
        raised: '\$600K',
        mrr: '\$52K',
        monthlyGrowth: '31%',
        runway: '8 months',
      ),
      const CompareStartupItem(
        id: 5,
        name: 'UrbanFarm',
        initials: 'UF',
        colorHex: 0xFFEF4444,
        score: 72,
        industry: 'CleanTech',
        stage: 'Pre-seed',
        raised: '\$300K',
        mrr: '\$28K',
        monthlyGrowth: '15%',
        runway: '6 months',
      ),
    ]);

    _savedContentItems.addAll([
      const ExploreContentItemModel(
        id: 1,
        type: ExploreContentType.community,
        title: 'FinTech Arabia',
        description:
            'Operators and investors building the future of financial services across MENA.',
        iconOrEmoji: '',
        subtitle: '12,400 members  340 posts',
      ),
      const ExploreContentItemModel(
        id: 2,
        type: ExploreContentType.knowledge,
        title: 'How to structure your Seed round term sheet',
        description:
            'A practical guide to the key clauses in a term sheet  —  from valuation to anti-dilution and board seats.',
        iconOrEmoji: '',
        subtitle: 'Fundraising  7 min read',
        author: 'Omar Khalil',
        readTime: '7 min',
      ),
      const ExploreContentItemModel(
        id: 3,
        type: ExploreContentType.discussion,
        title: 'What is your go-to due diligence checklist for seed deals?',
        description:
            'Sharing the checklist we use at Wamda for commercial and technical diligence.',
        iconOrEmoji: '',
        subtitle: 'FinTech Arabia  34 replies',
        repliesCount: 34,
      ),
      const ExploreContentItemModel(
        id: 4,
        type: ExploreContentType.challenge,
        title: 'MENA HealthTech Innovation 2026',
        description:
            'Public voting open for the most impactful clinical AI solution in the region.',
        iconOrEmoji: ' ',
        subtitle: 'Public voting  2 days left',
      ),
    ]);

    // Track saved keys
    _savedKeys.add('investor:1');
    _savedKeys.add('startup:2');
    _savedKeys.add('founder:1');
    _savedKeys.add('event:2');
    _savedKeys.add('community:1');
    _savedKeys.add('knowledge:2');
    _savedKeys.add('discussion:3');
    _savedKeys.add('challenge:4');
  }

  @override
  Future<List<ExploreStartup>> getStartups() async {
    return List.unmodifiable(_startups);
  }

  @override
  Future<List<ExploreInvestor>> getInvestors() async {
    return List.unmodifiable(_investors);
  }

  @override
  Future<List<ExploreFounder>> getFounders() async {
    return List.unmodifiable(_founders);
  }

  @override
  Future<List<ExploreEvent>> getEvents() async {
    return List.unmodifiable(_events);
  }

  @override
  Future<List<ExploreCampaign>> getCampaigns() async {
    return List.unmodifiable(_campaigns);
  }

  @override
  Future<List<CompareStartupItem>> getCompareStartups() async {
    return List.unmodifiable(_compareStartups);
  }

  @override
  Future<List<ExploreContentItem>> getSavedContentItems() async {
    return List.unmodifiable(_savedContentItems);
  }

  @override
  Future<bool> toggleBookmark(String type, int id) async {
    final key = '$type:$id';
    final wasSaved = _savedKeys.contains(key);
    if (wasSaved) {
      _savedKeys.remove(key);
    } else {
      _savedKeys.add(key);
    }
    final nowSaved = !wasSaved;

    // Mutate corresponding models in memory
    if (type == 'startup') {
      final index = _startups.indexWhere((s) => s.id == id);
      if (index != -1) {
        _startups[index] = _startups[index].copyWith(isSaved: nowSaved);
      }
    } else if (type == 'investor') {
      final index = _investors.indexWhere((i) => i.id == id);
      if (index != -1) {
        _investors[index] = _investors[index].copyWith(isSaved: nowSaved);
      }
    } else if (type == 'founder') {
      final index = _founders.indexWhere((f) => f.id == id);
      if (index != -1) {
        _founders[index] = _founders[index].copyWith(isSaved: nowSaved);
      }
    } else if (type == 'event') {
      final index = _events.indexWhere((e) => e.id == id);
      if (index != -1) {
        _events[index] = _events[index].copyWith(isSaved: nowSaved);
      }
    } else if (type == 'campaign') {
      final index = _campaigns.indexWhere((c) => c.id == id);
      if (index != -1) {
        _campaigns[index] = _campaigns[index].copyWith(isSaved: nowSaved);
      }
    }

    return nowSaved;
  }

  @override
  Future<bool> expressInterest(String type, int id) async {
    if (type == 'investor') {
      final index = _investors.indexWhere((i) => i.id == id);
      if (index != -1) {
        final current = _investors[index].isInterestSent;
        _investors[index] =
            _investors[index].copyWith(isInterestSent: !current);
        return !current;
      }
    } else if (type == 'founder') {
      final index = _founders.indexWhere((f) => f.id == id);
      if (index != -1) {
        final current = _founders[index].isInterestSent;
        _founders[index] =
            _founders[index].copyWith(isInterestSent: !current);
        return !current;
      }
    } else if (type == 'campaign') {
      final index = _campaigns.indexWhere((c) => c.id == id);
      if (index != -1) {
        final current = _campaigns[index].isInterested;
        _campaigns[index] =
            _campaigns[index].copyWith(isInterested: !current);
        return !current;
      }
    } else if (type == 'startup') {
      final index = _startups.indexWhere((s) => s.id == id);
      if (index != -1) {
        final current = _startups[index].isInterested;
        _startups[index] =
            _startups[index].copyWith(isInterested: !current);
        return !current;
      }
    }
    return true;
  }

  @override
  Future<bool> toggleFollow(String type, int id) async {
    if (type == 'investor') {
      final index = _investors.indexWhere((i) => i.id == id);
      if (index != -1) {
        final current = _investors[index].isFollowing;
        final newFollowing = !current;
        final newFollowers = newFollowing
            ? _investors[index].followers + 1
            : (_investors[index].followers - 1).clamp(0, 999999);
        _investors[index] = _investors[index].copyWith(
          isFollowing: newFollowing,
          followers: newFollowers,
        );
        return newFollowing;
      }
    } else if (type == 'founder') {
      final index = _founders.indexWhere((f) => f.id == id);
      if (index != -1) {
        final current = _founders[index].isFollowing;
        final newFollowing = !current;
        final newFollowers = newFollowing
            ? _founders[index].followers + 1
            : (_founders[index].followers - 1).clamp(0, 999999);
        _founders[index] = _founders[index].copyWith(
          isFollowing: newFollowing,
          followers: newFollowers,
        );
        return newFollowing;
      }
    }
    return true;
  }

  @override
  Future<bool> toggleEventRegistration(int eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final item = _events[index];
      final newRegistered = !item.isRegistered;
      final newCount = newRegistered ? item.attendeesCount + 1 : item.attendeesCount - 1;
      _events[index] = item.copyWith(
        isRegistered: newRegistered,
        attendeesCount: newCount > 0 ? newCount : 0,
      );
      return newRegistered;
    }
    return false;
  }
}
